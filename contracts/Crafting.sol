// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; 

// NFT 메인 컨트랙트를 참조합니다.
import "./ChamematItem.sol"; 

contract CraftingV1 {

    // 아이템 등급을 uint8로 매핑 (클라이언트에서 사용될 등급 ID)
    // 1: Normal, 2: Rare, 3: Epic, 4: Legendary
    enum Grade { Normal, Rare, Epic, Legendary }
    
    // 확률 결정에 필요한 가중치 상수
    uint256 constant SCORE_PER_RARE = 10; 
    uint256 constant SCORE_PER_EPIC = 30; 
    uint256 constant SCORE_PER_LEGENDARY = 80; 

    event CraftingResult(address indexed caller, uint256 totalScore, uint8 resultGrade);
    
    // ===============================================
    // ✅ NFT 컨트랙트 주소 상태 변수 (ChamematItem과 연동)
    // ===============================================
    ChamematItem private itemContract; 

    // ✅ 생성자: 배포 시 ChamematItem 컨트랙트 주소를 입력받아 저장합니다.
    constructor(address _itemContractAddress) {
        itemContract = ChamematItem(_itemContractAddress);
    }
    
    // 조합 로직 실행: 재료 토큰 ID를 추가로 받습니다.
    function executeCrafting(
        uint256[] memory slotScores,
        uint256[] memory materialTokenIds 
    ) 
        public 
        returns (uint256 newItemId) // 민팅된 새 아이템의 ID를 반환
    {
        require(slotScores.length == 4, "4 material slots are required.");
        require(materialTokenIds.length == 4, "4 material token IDs are required.");
        
        uint256 totalScore = 0;
        for (uint i = 0; i < slotScores.length; i++) {
            totalScore += slotScores[i];
        }

        // ----------------------------------------------------
        // [1] 결과 등급 결정 로직 (계산)
        // ----------------------------------------------------
        uint8 finalGrade;
        uint256 randomSeed = uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), totalScore)));
        uint256 randomValue = randomSeed % 1000; 
        uint256 legendaryThreshold = (totalScore > SCORE_PER_LEGENDARY) ? (totalScore - SCORE_PER_LEGENDARY) * 10 : 0; 
        uint256 epicThreshold = (totalScore > SCORE_PER_EPIC) ? (totalScore - SCORE_PER_EPIC) * 20 : 0;
        
        if (totalScore >= SCORE_PER_LEGENDARY && randomValue < legendaryThreshold) {
            finalGrade = uint8(Grade.Legendary);
        } else if (totalScore >= SCORE_PER_EPIC && randomValue < epicThreshold) {
            finalGrade = uint8(Grade.Epic);
        } else if (totalScore >= SCORE_PER_RARE * 2) {
            finalGrade = uint8(Grade.Rare);
        } else {
            finalGrade = uint8(Grade.Normal);
        }

        emit CraftingResult(msg.sender, totalScore, finalGrade);
        
        // ----------------------------------------------------
        // [2] NFT 컨트랙트 호출 및 상태 변경
        // ----------------------------------------------------
        
        // ChamematItem 컨트랙트의 processCrafting 함수를 호출합니다.
        uint256 mintedId = itemContract.processCrafting(
            msg.sender, 
            finalGrade,
            materialTokenIds 
        );

        return mintedId;
    }
}
