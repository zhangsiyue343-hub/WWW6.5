// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {

    // 状态变量
    uint256 public counter;

    // 增加1
    function click() public {
        counter++;
    }

    // 1️⃣ 重置为0
    function reset() public {
        counter = 0;
    }

    // 2️⃣ 减1（不能小于0）
    function decrease() public {
        require(counter > 0, "Counter is already zero");
        counter--;
    }

    // 3️⃣ 返回当前值（view 表示不修改区块链）
    function getCounter() public view returns (uint256) {
        return counter;
    }

    // 4️⃣ 一次增加多次
    function clickMultiple(uint256 times) public {
        counter += times;
    }
}
