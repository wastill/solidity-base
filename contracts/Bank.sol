// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 引入接口
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
contract Bank {
    // 状态变量
    address public immutable owner;
    // ETH以外的资产
    mapping(address => mapping(address => uint256)) public balances;
    // 事件
    // 存入
    event Deposit(address indexed from, uint256 value);
    // 取出
    event Withdraw(uint256 value);
    // receive  solidity 的回调函数，在接收到以太币时触发
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    constructor() payable {
        owner = msg.sender;
    }

    // 所有人都可以存钱
    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }
        // 存款
    function depositToken(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount");
        // 转移资产到合约
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        // 更新余额
        balances[msg.sender][token] += amount;
        emit Deposit(msg.sender, amount);
    }
    // 取款
    function withdraw(uint256 value) external {
        require(msg.sender == owner, "only owner can withdraw");
        require(address(this).balance >= value, "insufficient balance");
        payable(msg.sender).transfer(value);
        emit Withdraw(value);
        this.destory();
    }
    // 获取金额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    // 销毁合约
    function destory() external {
        require(msg.sender == owner, "only owner can destroy");
        selfdestruct(payable(owner)); 
        // payable(owner).transfer(address(this).balance); 
    }
    // 扩展 
    // ERC20
    function depositERC20Token(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount");
        // 转移资产到合约
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        // 更新余额
        balances[msg.sender][token] += amount;
        emit Deposit(msg.sender, amount);
    }
    // 取款
    function withdrawERC20(address token, uint256 amount) external {
        require(msg.sender == owner, "only owner can withdraw");
        require(address(this).balance >= amount, "insufficient balance");
        // 转移资产给用户Q
        require(IERC20(token).transfer(msg.sender, amount), "Token transfer failed");
        
        // 更新余额
        balances[msg.sender][token] -= amount;
        emit Withdraw(amount);
        this.destory();
    }
    // ERC721
    function depositERC721Token(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount");
        // 转移资产到合约
        IERC721(token).transferFrom(msg.sender, address(this), amount);
        // 更新余额
        balances[msg.sender][token] += amount;
        emit Deposit(msg.sender, amount);
    }
    // 取款
    function withdrawERC721(address token, uint256 amount) external {
        require(msg.sender == owner, "only owner can withdraw");
        require(address(this).balance >= amount, "insufficient balance");
        // 转移资产给用户Q
        require(IERC721(token).transfer(msg.sender, amount), "Token transfer failed");
        
        // 更新余额
        balances[msg.sender][token] -= amount;
        emit Withdraw(amount);
        this.destory();
    }
}