// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/** 
 多签钱包的功能: 合约有多个 owner，一笔交易发出后，需要多个 owner 确认，确认数达到最低要求数之后，才可以真正的执行。

### 1.原理

- 部署时候传入地址参数和需要的签名数
  - 多个 owner 地址
  - 发起交易的最低签名数
- 有接受 ETH 主币的方法，
- 除了存款外，其他所有方法都需要 owner 地址才可以触发
- 发送前需要检测是否获得了足够的签名数
- 使用发出的交易数量值作为签名的凭据 ID（类似上么）
- 每次修改状态变量都需要抛出事件
- 允许批准的交易，在没有真正执行前取消。
- 足够数量的 approve 后，才允许真正执行。
*/

contract MutiSigWallet {
    // owner地址
    address[] public owners;
    // 最低签名数
    uint256 public required;
    // 是否是 owner
    mapping(address => bool) public isOwner;
    // 投票人数
    uint256 public transactionCount;
    // 投票结果
    mapping(uint256 => Transaction) public transactions;
    // 投票内容
    struct Transaction {
        // 目标地址
        address to;
        // 金额
        uint256 value;
        // 数据
        bytes data;
        // 是否执行
        bool executed;
        // 投票数
        uint256 confirmations;
    }
    // 事件 Deposit 提现
    event Deposit(address indexed sender, uint256 value, uint256 indexed balance);
    // 提交事务
    event SubmitTransaction(
        // 提交人
        address indexed owner,
        // 事务ID
        uint256 indexed transactionId,
        // 目标地址
        address indexed to,
        // 金额
        uint256 value,
        // 数据
        bytes data
    );
    // 确认事务
    event ConfirmTransaction(address indexed owner, uint256 indexed transactionId);
    // 取消确认
    event RevokeConfirmation(address indexed owner, uint256 indexed transactionId);
    // 执行事务
    event ExecuteTransaction(address indexed owner, uint256 indexed transactionId);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "required error");
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "owner error");
            require(!isOwner[owner], "owner duplicate");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(address to, uint256 value, bytes memory data) public onlyOwner {
        uint256 transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 0
        });
        transactionCount += 1;
        emit SubmitTransaction(msg.sender, transactionId, to, value, data);
    }

    function confirmTransaction(uint256 transactionId) public onlyOwner {
        Transaction storage transaction = transactions[transactionId];
        require(!transaction.executed, "transaction executed");
        require(!transactionIsConfirmed(transactionId, msg.sender), "transaction confirmed");
        transaction.confirmations += 1;
        emit ConfirmTransaction(msg.sender, transactionId);
    }

    function revokeConfirmation(uint256 transactionId) public onlyOwner {
        Transaction storage transaction = transactions[transactionId];
        require(!transaction.executed, "transaction executed");
        require(transactionIsConfirmed(transactionId, msg.sender), "transaction not confirmed");
        transaction.confirmations -= 1;
        emit RevokeConfirmation(msg.sender, transactionId);
    }

    function transactionIsConfirmed(uint256 transactionId, address owner) public view returns (bool) {
        Transaction storage transaction = transactions[transactionId];
        return transaction.confirmations >= required;
    }
}