// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义一个简单的点击计数合约
contract ClickCounter {

    // 状态变量：用于存储点击次数
    // public 表示任何人都可以读取这个值
    uint256 public counter;

    // click() 函数：每调用一次，计数器加 1
    function click() public {
        counter++;
    }

    // reset() 函数：将计数器重置为 0
    function reset() public {
        counter = 0;
    }

    // decrease() 函数：将计数器减 1
    // require 用于检查条件，防止计数器变成负数
    function decrease() public {
        require(counter > 0, "Counter is already zero");
        counter--;
    }

    // clickMultiple() 函数：一次增加多次点击
    // 参数 times 表示要增加的次数
    function clickMultiple(uint256 times) public {
        counter += times;
    }
}
