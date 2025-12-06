// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 🛑 이 경로들이 Remix 파일 시스템 내에서 OpenZeppelin 라이브러리를 가리킵니다.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/utils/Counters.sol"; 

using Counters for Counters.Counter;

contract ChamematItem is ERC721, Ownable {
    
    Counters.Counter private _tokenIdCounter;
    address public immutable CRAFTING_CONTRACT; 

    constructor(address _craftingContractAddress)
        ERC721("Chamemat Item", "CMITEM")
        Ownable(msg.sender)
    {
        CRAFTING_CONTRACT = _craftingContractAddress;
    }

    function processCrafting(
        address to, 
        uint8 resultGrade, 
        uint256[] calldata materialTokenIds
    ) public returns (uint256 newItemId) {
        
        // 1. 재료 NFT 소각 (Burning)
        require(materialTokenIds.length == 4, "4 material token IDs must be supplied.");
        for (uint i = 0; i < materialTokenIds.length; i++) {
            _burn(materialTokenIds[i]); 
        }
        
        // 2. 새로운 아이템 NFT 민팅 (Minting)
        _tokenIdCounter.increment();
        uint256 newId = _tokenIdCounter.current();
        
        _safeMint(to, newId);
        // [TODO: 스탯/티어 저장 로직 추가 필요]
        
        return newId;
    }

    function mintForTest(address to) public onlyOwner returns (uint256) {
        _tokenIdCounter.increment();
        uint256 newItemId = _tokenIdCounter.current();
        _safeMint(to, newItemId);
        return newItemId;
    }
    
    // 이외 ERC-721 표준 함수들 (tokenURI, supportsInterface 등)은 OpenZeppelin에 의해 자동 구현됩니다.
}
