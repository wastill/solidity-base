// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
众筹合约分为两种角色：一个是受益人，一个是资助者。

```
// 两种角色:
//      受益人   beneficiary => address         => address 类型
//      资助者   funders     => address:amount  => mapping 类型 或者 struct 类型
```

```
状态变量按照众筹的业务：
// 状态变量
//      筹资目标数量    fundingGoal
//      当前募集数量    fundingAmount
//      资助者列表      funders
//      资助者人数      fundersKey
```

```
需要部署时候传入的数据:
//      受益人
//      筹资目标数量
```

### 
 */
contract Crowdfunding {
    // 状态变量
    address public immutable beneficiary;
    uint256 public immutable fundingGoal;
    uint256 public fundingAmount;
    mapping(address => uint256) public funders;
    uint256 public fundersKey;

    // 事件
    event FundingReceived(address indexed funder, uint256 indexed amount, uint256 indexed fundingAmount);
    event FundingGoalReached(uint256 indexed fundingAmount);
    event BeneficiaryPaid(address indexed beneficiary, uint256 indexed fundingAmount);

    // 构造函数
    constructor(address _beneficiary, uint256 _fundingGoal) {
        beneficiary = _beneficiary; // 受益人
        fundingGoal = _fundingGoal; // 筹资目标数量
    }

    // 资助
    function fund(uint amount) external payable {
        require(amount > 0, "Invalid amount");
        fundingAmount += amount;
        funders[msg.sender] += amount;
        fundersKey += 1;
        emit FundingReceived(msg.sender, msg.value, fundingAmount);
        if (fundingAmount >= fundingGoal) {
            emit FundingGoalReached(fundingAmount);
        }
    }

    // 提款
    function withdraw() external {
        require(msg.sender == beneficiary, "only beneficiary can withdraw");
        require(fundingAmount >= fundingGoal, "funding goal not reached");
        payable(beneficiary).transfer(fundingAmount);
        emit BeneficiaryPaid(beneficiary, fundingAmount);
        fundingAmount = 0;
    }

}