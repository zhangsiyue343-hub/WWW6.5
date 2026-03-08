// SPDX-License-Identifier: MIT
// SPDX 是开源许可证标识，MIT 表示允许他人自由使用代码

pragma solidity ^0.8.0;
// 指定 Solidity 编译器版本，0.8.0 及以上版本都可以编译

contract SaveMyName {

    // 状态变量（State Variables）
    // 这些变量会永久存储在区块链上

    string public name;
    // 存储用户的名字
    // public 表示变量可以被外部读取
    // Solidity 会自动生成一个 getter 函数

    string public bio;
    // 存储用户的个人简介

    // 添加或更新用户信息
    function add(string memory _name, string memory _bio) public {

        // memory 表示临时变量，只在函数执行时存在
        // _name 和 _bio 是函数参数

        name = _name;
        // 把输入的名字保存到区块链

        bio = _bio;
        // 把输入的简介保存到区块链
    }

    // 单独更新 bio（可选功能）
    function updateBio(string memory _bio) public {

        bio = _bio;
        // 修改已经存储的 bio
    }

    // 读取存储的信息
    function retrieve() public view returns(string memory, string memory){

        // view 表示这个函数不会修改区块链数据

        return (name, bio);
        // 返回 name 和 bio
    }

}
