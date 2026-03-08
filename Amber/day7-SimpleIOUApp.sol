// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleIOU {
    // -----------------------------
    // 合约所有者（管理员）
    // -----------------------------
    address public owner;
    
    // -----------------------------
    // 好友注册管理
    // registeredFriends 用于快速判断某地址是否已注册
    // friendList 用于保存所有已注册好友的列表
    // -----------------------------
    mapping(address => bool) public registeredFriends;
    address[] public friendList;
    
    // -----------------------------
    // 用户 ETH 余额
    // -----------------------------
    mapping(address => uint256) public balances;
    
    // -----------------------------
    // 债务记录
    // debts[debtor][creditor] = 债务金额
    // -----------------------------
    mapping(address => mapping(address => uint256)) public debts; 
    
    // -----------------------------
    // 构造函数
    // 部署合约的人为 owner，并默认注册自己
    // -----------------------------
    constructor() {
        owner = msg.sender;
        registeredFriends[msg.sender] = true;
        friendList.push(msg.sender);
    }
    
    // -----------------------------
    // 修饰符：只有合约所有者能调用
    // -----------------------------
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // -----------------------------
    // 修饰符：只有注册用户能调用
    // -----------------------------
    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "You are not registered");
        _;
    }
    
    // -----------------------------
    // 添加新好友（仅 owner 可操作）
    // -----------------------------
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address"); // 防止零地址
        require(!registeredFriends[_friend], "Friend already registered"); // 防止重复注册
        
        registeredFriends[_friend] = true; // 注册好友
        friendList.push(_friend);           // 添加到列表
    }
    
    // -----------------------------
    // 存入 ETH 到合约余额
    // -----------------------------
    function depositIntoWallet() public payable onlyRegistered {
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;
    }
    
    // -----------------------------
    // 记录某人欠你的债务
    // _debtor 欠款人
    // _amount 欠款金额
    // -----------------------------
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        require(_debtor != address(0), "Invalid address");
        require(registeredFriends[_debtor], "Address not registered"); // 债务人必须注册
        require(_amount > 0, "Amount must be greater than 0");
        
        debts[_debtor][msg.sender] += _amount; // 更新债务映射
    }
    
    // -----------------------------
    // 使用内部余额支付债务
    // _creditor 收款人
    // _amount 支付金额
    // -----------------------------
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
        require(_creditor != address(0), "Invalid address");
        require(registeredFriends[_creditor], "Creditor not registered"); // 收款人必须注册
        require(_amount > 0, "Amount must be greater than 0");
        require(debts[msg.sender][_creditor] >= _amount, "Debt amount incorrect"); // 不超过欠款
        require(balances[msg.sender] >= _amount, "Insufficient balance"); // 余额不足
        
        // 更新余额与债务
        balances[msg.sender] -= _amount;
        balances[_creditor] += _amount;
        debts[msg.sender][_creditor] -= _amount;
    }
    
    // -----------------------------
    // 直接用 transfer() 转账 ETH 给好友
    // -----------------------------
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered"); // 收款人必须注册
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount; // 先扣余额
        _to.transfer(_amount);           // 转账
        balances[_to] += _amount;        // 更新接收者内部余额
    }
    
    // -----------------------------
    // 使用 call() 转账 ETH（更安全，现代做法）
    // -----------------------------
    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount; // 先扣余额
        
        (bool success, ) = _to.call{value: _amount}(""); // call 转账
        require(success, "Transfer failed");
        balances[_to] += _amount; // 更新接收者内部余额
    }
    
    // -----------------------------
    // 提现，将内部余额提取到自己的钱包
    // -----------------------------
    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount; // 先扣余额
        
        (bool success, ) = payable(msg.sender).call{value: _amount}(""); // 提现
        require(success, "Withdrawal failed");
    }
    
    // -----------------------------
    // 查看自己的内部余额
    // -----------------------------
    function checkBalance() public view onlyRegistered returns (uint256) {
        return balances[msg.sender];
    }
}
