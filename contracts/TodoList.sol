// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
1.需要完成的功能

- 创建任务
- 修改任务名称
  - 任务名写错的时候
- 修改完成状态：
  - 手动指定完成或者未完成
  - 自动切换
    - 如果未完成状态下，改为完成
    - 如果完成状态，改为未完成
- 获取任务
2.思考代码内状态变量怎么安排？
  思考 1：思考任务 ID 的来源？
  我们在传统业务里，这里的任务都会有一个任务 ID，在区块链里怎么实现？？
  答：传统业务里，ID 可以是数据库自动生成的，也可以用算法来计算出来的，比如使用雪花算法计算出 ID 等。在区块链里我们使用数组的 index 索引作为任务的 ID，也可以使用自增的整型数据来表示。
  思考 2: 我们使用什么数据类型比较好？
  答：因为需要任务 ID，如果使用数组 index 作为任务 ID。则数据的元素内需要记录任务名称，任务完成状态，所以元素使用 struct 比较好。
  如果使用自增的整型作为任务 ID，则整型 ID 对应任务，使用 mapping 类型比较符合。
 */
contract TodoList {
    struct Task {
        string name;
        Status taskStatus;
    }
    enum Status {
        Pending,
        Completed
    }
    Task[] public tasks;
    // 创建任务
    function CreateTask(string calldata name) public {
        tasks.push(Task(name, Status.Pending));
    }
    // 修改任务名称
    function modifyTaskName(uint256 index, string calldata name) public {
        Task storage task = tasks[index];
        task.name = name;
    }
    // 手动修改任务状态
    function modiStatus (uint256 index, Status status) public {
        Task storage task = tasks[index];
        task.taskStatus = status;
    }
    // 自动修改任务状态
    function ToggleStatus(uint256 index) public {
        Task storage task = tasks[index];
        if (task.taskStatus == Status.Pending) {
            task.taskStatus = Status.Completed;
        } else {
            task.taskStatus = Status.Pending;
        }
    }
}