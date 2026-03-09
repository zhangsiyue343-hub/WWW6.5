// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract TipJar {

    // 合约拥有者（部署合约的人）
    address public owner;
    
    // 合约一共收到多少 ETH（单位：wei）
    uint256 public totalTipsReceived;
    
    // 货币转换汇率
    // 例如：1 USD = 0.0005 ETH → 5 * 10^14 wei
    mapping(string => uint256) public conversionRates;

    // 记录每个地址打赏了多少 ETH
    mapping(address => uint256) public tipPerPerson;

    // 支持的货币列表
    string[] public supportedCurrencies;

    // 每种货币收到多少打赏
    mapping(string => uint256) public tipsPerCurrency;
    
    // 构造函数，在部署合约时自动执行
    constructor() {

        // 部署者成为合约 owner
        owner = msg.sender;

        // 添加支持的货币以及汇率
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007 ETH
    }
    
    // modifier：限制只有 owner 可以执行某些函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 添加或更新支持的货币
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {

        // 汇率必须大于0
        require(_rateToEth > 0, "Conversion rate must be greater than 0");

        bool currencyExists = false;

        // 遍历 supportedCurrencies 数组，检查货币是否已存在
        for (uint i = 0; i < supportedCurrencies.length; i++) {

            // keccak256 用于比较字符串是否相同
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }

        // 如果货币不存在，则加入支持列表
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }

        // 设置或更新汇率
        conversionRates[_currencyCode] = _rateToEth;
    }
    
    // 将某种货币金额转换为 ETH
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {

        // 检查货币是否支持
        require(conversionRates[_currencyCode] > 0, "Currency not supported");

        // 根据汇率计算对应的 ETH 数量
        uint256 ethAmount = _amount * conversionRates[_currencyCode];

        return ethAmount;

        // 如果前端需要显示 ETH，可以再除以 10^18 转成人类可读的 ETH
    }
    
    // 直接用 ETH 打赏
    function tipInEth() public payable {

        // 打赏金额必须大于0
        require(msg.value > 0, "Tip amount must be greater than 0");

        // 记录打赏人贡献
        tipPerPerson[msg.sender] += msg.value;

        // 更新总打赏
        totalTipsReceived += msg.value;

        // 记录 ETH 打赏金额
        tipsPerCurrency["ETH"] += msg.value;
    }
    
    // 用外币打赏（需要发送等值 ETH）
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {

        // 检查货币是否支持
        require(conversionRates[_currencyCode] > 0, "Currency not supported");

        // 金额必须大于0
        require(_amount > 0, "Amount must be greater than 0");

        // 将外币转换成 ETH
        uint256 ethAmount = convertToEth(_currencyCode, _amount);

        // 用户发送的 ETH 必须等于计算后的 ETH
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

        // 更新记录
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;

        // 记录该货币打赏数量
        tipsPerCurrency[_currencyCode] += _amount;
    }

    // 提现所有打赏（只有 owner 可以）
    function withdrawTips() public onlyOwner {

        // 获取合约余额
        uint256 contractBalance = address(this).balance;

        // 必须有余额
        require(contractBalance > 0, "No tips to withdraw");

        // 使用 call 转账 ETH（推荐的安全方式）
        (bool success, ) = payable(owner).call{value: contractBalance}("");

        require(success, "Transfer failed");

        // 提现后重置总记录
        totalTipsReceived = 0;
    }
  
    // 转移合约所有权
    function transferOwnership(address _newOwner) public onlyOwner {

        // 新 owner 地址不能是空地址
        require(_newOwner != address(0), "Invalid address");

        owner = _newOwner;
    }

    // 获取支持的货币列表
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }
    
    // 获取合约当前余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // 查询某个地址打赏了多少
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }
    
    // 查询某种货币收到多少打赏
    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    // 查询某种货币的汇率
    function getConversionRate(string memory _currencyCode) public view returns (uint256) {

        // 必须是支持的货币
        require(conversionRates[_currencyCode] > 0, "Currency not supported");

        return conversionRates[_currencyCode];
    }
}
