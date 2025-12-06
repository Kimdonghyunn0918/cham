// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ChamematItem.sol";

contract DutchAuction {
    ChamematItem public immutable nft;
    uint256 public immutable nftId;
    uint256 public startingPrice;
    uint256 public startAt;
    uint256 public expiresAt;
    uint256 public discountRate;
    address payable public seller;
    bool public ended;

    constructor(
        address _nft,
        uint256 _nftId,
        uint256 _startingPrice,
        uint256 _durationSeconds,
        uint256 _discountRate
    ) {
        nft = ChamematItem(_nft);
        nftId = _nftId;
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + _durationSeconds;
        seller = payable(msg.sender);
    }

    function getCurrentPrice() public view returns (uint256) {
        if (block.timestamp >= expiresAt) return 0;
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice > discount ? startingPrice - discount : 0;
    }

    function buy() external payable {
        require(!ended, "Auction ended");
        uint256 price = getCurrentPrice();
        require(msg.value >= price, "Not enough ETH");

        ended = true;
        nft.transferFrom(seller, msg.sender, nftId);

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        seller.transfer(price);
    }
}
