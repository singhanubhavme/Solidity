// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
        deadline = block.timestamp + 72 hours;
    }

    event Stake(address who, uint256 howMuch);

    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    uint256 public deadline;
    bool public openForWithdraw;
    bool public hasExecuted;

    function execute() public {
        require(block.timestamp > deadline, "Not Yet");
        require(!hasExecuted, "Already Done");
        hasExecuted = true;

        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() public {
        require(openForWithdraw, "Not Open for Withdraw");
        require(balances[msg.sender] > 0, "No Balance");

        uint256 temp = balances[msg.sender]; // temp is used to not allow any kind of recursion attacks which calls transfer without setting balance to 0
        balances[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: temp}("");
        require(sent, "Failed to send Ether");
        // if (temp > 0) {
        //     payable(msg.sender).transfer(temp);
        // }
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function reveive() external payable {
        stake();
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function

    // Add a `withdraw()` function to let users withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()
}
