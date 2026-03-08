// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {

    address public owner;          // 拍卖创建者
    string public item;            // 拍卖物品名称
    uint public auctionEndTime;    // 拍卖结束时间
    uint public startingPrice;     // 起拍价

    address private highestBidder; // 当前最高出价者
    uint private highestBid;       // 当前最高出价

    bool public ended;             // 拍卖是否结束

    mapping(address => uint) public bids; // 记录每个地址的出价
    address[] public bidders;             // 存储所有参与者地址

    uint constant MIN_INCREMENT_PERCENT = 5; // 最低加价比例 5%

    // -----------------------------
    // 构造函数：初始化拍卖
    // -----------------------------
    constructor(
        string memory _item,
        uint _biddingTime,
        uint _startingPrice
    ) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime; // 拍卖结束时间 = 当前时间 + 持续时间
        startingPrice = _startingPrice;
        highestBid = _startingPrice; // 初始最高价为起拍价
    }

    // -----------------------------
    // 出价函数
    // -----------------------------
    function bid(uint amount) external {

        require(block.timestamp < auctionEndTime, "拍卖已结束"); // 拍卖未结束才能出价
        require(amount >= startingPrice, "出价必须大于等于起拍价"); // 出价 >= 起拍价
        require(amount > bids[msg.sender], "新出价必须高于你之前的出价"); // 不能低于自己之前的出价

        // 如果已有最高出价，要求至少加 5%
        if (highestBid > 0) {
            uint minBid = highestBid + (highestBid * MIN_INCREMENT_PERCENT / 100);
            require(amount >= minBid, "出价必须至少比当前最高出价高5%");
        }

        // 第一次出价的用户，记录地址
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = amount; // 更新用户出价

        // 更新最高出价和最高出价者
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    // -----------------------------
    // 未中奖者撤回出价
    // -----------------------------
    function withdrawBid() external {
        require(block.timestamp < auctionEndTime, "拍卖已结束"); // 拍卖进行中才允许撤回
        require(msg.sender != highestBidder, "最高出价者不能撤回"); // 最高出价者不能撤回

        uint amount = bids[msg.sender];
        require(amount > 0, "你没有出价可撤回");

        bids[msg.sender] = 0; // 将出价清零
        // 实际拍卖里可以转账，这里仅作作业逻辑
    }

    // -----------------------------
    // 结束拍卖
    // -----------------------------
    function endAuction() external {
        require(block.timestamp >= auctionEndTime, "拍卖未结束"); // 时间到了才能结束
        require(!ended, "拍卖已结束");

        ended = true; // 标记拍卖结束
    }

    // -----------------------------
    // 查询所有竞拍者
    // -----------------------------
    function getAllBidders() external view returns(address[] memory) {
        return bidders;
    }

    // -----------------------------
    // 查询赢家及其出价
    // -----------------------------
    function getWinner() external view returns(address, uint) {
        require(ended, "拍卖尚未结束");
        return (highestBidder, highestBid);
    }
}
