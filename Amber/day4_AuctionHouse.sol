// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {

    address public owner; // 拍卖创建者
    string public item; // 拍卖物品
    uint256 public auctionEndTime; // 拍卖结束时间
    uint256 public startingPrice; // 起拍价

    address private highestBidder; // 当前最高出价者
    uint256 private highestBid; // 当前最高出价

    bool public ended; // 拍卖是否结束

    mapping(address => uint256) public bids; // 记录每个地址的出价
    address[] public bidders; // 记录所有竞拍者

    uint256 constant MIN_INCREMENT = 5; // 最低加价 5%

    // 初始化拍卖
    constructor(
        string memory _item,
        uint256 _biddingTime,
        uint256 _startingPrice
    ) {
        owner = msg.sender;
        item = _item;

        auctionEndTime = block.timestamp + _biddingTime;
        startingPrice = _startingPrice;

        highestBid = _startingPrice;
    }

    // 出价函数
    function bid(uint256 amount) public {

        require(block.timestamp < auctionEndTime, "Auction ended");
        require(amount >= startingPrice, "Bid lower than starting price");
        require(amount > bids[msg.sender], "Must be higher than your last bid");

        // 最低加价 5%
        uint256 minBid = highestBid + (highestBid * MIN_INCREMENT / 100);
        require(amount >= minBid, "Bid must be 5% higher");

        // 第一次出价记录地址
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = amount;

        // 更新最高价
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    // 未成为最高价者可以撤回
    function withdrawBid() public {

        require(msg.sender != highestBidder, "Highest bidder cannot withdraw");

        uint256 amount = bids[msg.sender];
        require(amount > 0, "No bid to withdraw");

        bids[msg.sender] = 0;
    }

    // 结束拍卖
    function endAuction() public {

        require(block.timestamp >= auctionEndTime, "Auction not finished");
        require(!ended, "Auction already ended");

        ended = true;
    }

    // 查询所有竞拍者
    function getAllBidders() public view returns(address[] memory) {
        return bidders;
    }

    // 查询赢家
    function getWinner() public view returns(address, uint256) {

        require(ended, "Auction not ended yet");

        return (highestBidder, highestBid);
    }
}
