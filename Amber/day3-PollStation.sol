// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollStation {

    // 存储候选人名字
    string[] public candidateNames;

    // 记录每个候选人的票数
    mapping(string => uint256) private voteCount;

    // 记录每个地址是否已经投过票
    mapping(address => bool) public hasVoted;

    // 合约管理员（部署者）
    address public owner;

    // 构造函数：部署者成为管理员
    constructor() {
        owner = msg.sender;
    }

    // 添加候选人
    // 只有管理员可以添加，且不能重复
    function addCandidateNames(string memory _candidateNames) public {
        require(msg.sender == owner, "Only owner can add candidates");

        // 防止重复候选人
        for (uint i = 0; i < candidateNames.length; i++) {
            require(
                keccak256(bytes(candidateNames[i])) != keccak256(bytes(_candidateNames)),
                "Candidate already exists"
            );
        }

        candidateNames.push(_candidateNames);  // 添加候选人
        voteCount[_candidateNames] = 0;        // 初始化票数为0
    }

    // 获取所有候选人名字
    function getcandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    // 给候选人投票
    // 每个地址只能投一次票
    // 投票前检查候选人是否存在
    function vote(string memory _candidateNames) public {
        require(!hasVoted[msg.sender], "You have already voted"); // 防止重复投票

        // 检查候选人是否存在
        bool exists = false;
        for (uint i = 0; i < candidateNames.length; i++) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateNames))) {
                exists = true;
                break;
            }
        }
        require(exists, "Candidate does not exist");

        voteCount[_candidateNames] += 1;  // 增加票数
        hasVoted[msg.sender] = true;       // 标记已投票
    }

    // 查询候选人的票数
    // 投票前检查候选人是否存在
    function getVote(string memory _candidateNames) public view returns (uint256) {
        bool exists = false;
        for (uint i = 0; i < candidateNames.length; i++) {
            if (keccak256(bytes(candidateNames[i])) == keccak256(bytes(_candidateNames))) {
                exists = true;
                break;
            }
        }
        require(exists, "Candidate does not exist");

        return voteCount[_candidateNames];
    }
}
