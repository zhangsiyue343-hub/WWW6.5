// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {

    // 合约拥有者（部署合约的人）
    address public owner;
    
    // 用户资料结构体
    struct UserProfile {
        string name;        // 用户名字
        uint256 weight;     // 用户体重
        bool isRegistered;  // 是否已经注册
    }
    
    // 运动记录结构体
    struct WorkoutActivity {
        string activityType; // 运动类型（跑步、骑行等）
        uint256 duration;    // 运动持续时间（秒）
        uint256 distance;    // 运动距离（米）
        uint256 timestamp;   // 记录时间
    }
    
    // 保存每个地址对应的用户资料
    mapping(address => UserProfile) public userProfiles;
    
    // 保存每个用户的所有运动记录
    mapping(address => WorkoutActivity[]) private workoutHistory;
    
    // 记录每个用户完成的运动次数
    mapping(address => uint256) public totalWorkouts;
    
    // 记录每个用户的总运动距离
    mapping(address => uint256) public totalDistance;
    
    
    // 用户注册时触发事件
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    
    // 用户更新资料时触发事件
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    
    // 用户记录一次运动时触发
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    
    // 当用户达到某个里程碑时触发
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    
    // 构造函数：部署合约时自动执行
    constructor() {
        owner = msg.sender;
    }
    
    
    // 修饰器：只允许已注册用户执行
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    
    // 注册用户
    function registerUser(string memory _name, uint256 _weight) public {
        
        // 确保用户还没有注册
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        // 创建用户资料
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // 触发注册事件
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    
    // 更新用户体重
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        
        // 获取用户资料
        UserProfile storage profile = userProfiles[msg.sender];
        
        // 如果体重减少超过5%，触发里程碑事件
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        // 更新体重
        profile.weight = _newWeight;
        
        // 触发资料更新事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    
    // 记录一次运动
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        
        // 创建新的运动记录
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        // 保存到用户历史记录
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新总运动次数
        totalWorkouts[msg.sender]++;
        
        // 更新总距离
        totalDistance[msg.sender] += _distance;
        
        // 触发运动记录事件
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        // 检查运动次数里程碑
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } 
        else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // 检查距离里程碑（100km = 100000米）
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    
    // 获取用户的运动次数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }

}
