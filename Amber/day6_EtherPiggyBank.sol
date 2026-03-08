// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherPiggyBank {
    // 银行经理
    address public bankManager;
    
    // 成员列表
    address[] public members;
    mapping(address => bool) public registeredMembers;
    
    // 成员余额
    mapping(address => uint256) private balance;
    
    // 上次取款时间，用于每日取款限制
    mapping(address => uint256) private lastWithdrawTime;
    uint256 public withdrawCooldown = 1 days;

    // 事件，方便链上追踪
    event MemberAdded(address member);
    event Deposit(address member, uint256 amount);
    event Withdrawal(address member, uint256 amount);

    constructor() {
        bankManager = msg.sender;
        members.push(msg.sender);
        registeredMembers[msg.sender] = true;
    }

    // 仅银行经理可操作
    modifier onlyBankManager() {
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        _;
    }

    // 仅注册成员可操作
    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Member not registered");
        _;
    }

    // 添加新成员
    function addMember(address _member) public onlyBankManager {
        require(_member != address(0), "Invalid address");
        require(!registeredMembers[_member], "Member already registered");
        registeredMembers[_member] = true;
        members.push(_member);
        emit MemberAdded(_member);
    }

    // 查看成员列表
    function getMembers() public view returns (address[] memory) {
        return members;
    }

    // 存款（以太币）
    function deposit() public payable onlyRegisteredMember {
        require(msg.value > 0, "Deposit must be greater than 0");
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 取款（有每日冷却）
    function withdraw(uint256 _amount) public onlyRegisteredMember {
        require(_amount > 0, "Withdrawal must be greater than 0");
        require(balance[msg.sender] >= _amount, "Insufficient balance");
        require(block.timestamp - lastWithdrawTime[msg.sender] >= withdrawCooldown, "Wait before next withdrawal");

        balance[msg.sender] -= _amount;
        lastWithdrawTime[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(_amount);
        emit Withdrawal(msg.sender, _amount);
    }

    // 查询余额
    function getBalance(address _member) public view returns (uint256) {
        require(_member != address(0), "Invalid address");
        return balance[_member];
    }
}
