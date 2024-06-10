// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
- 任何人都可以发送金额到合约
- 只有 owner 可以取款
- 3 种取钱方式
 */
contract Wallet {
    address owner;
    event Received(address, uint256);

    constructor() {
        owner = msg.sender;
    }
    
    function withDraw1() public {
        require(msg.sender == owner, "only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }

    function withDraw2() external {
        require(msg.sender == owner, "only owner can withdraw");
        (bool result,) = msg.sender.call{value: address(this).balance}("");
        require(result, "Transfer failed");
    }

    function withDraw3() public payable {
        require(msg.sender == owner, "only owner can withdraw");
        bool success = payable(msg.sender).send(msg.value);
        require(success, "Transfer failed");
    }

    // receive
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}