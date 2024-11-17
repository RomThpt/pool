// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Pool contract
/// @author RomThpt
/// @notice This contract handles the core functionality of the pool.
/// It includes mechanisms for managing liquidity, handling deposits and withdrawals,
/// and ensuring the proper distribution of rewards among participants.

import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract Pool is Ownable {
    ///////////////////////
    //  Error messages   //
    ///////////////////////
    error Pool__CollectIsFinished();
    error Pool__GoalIsAlreadyReached();
    error Pool__CollectIsNotFinished();
    error Pool__FailedToSendEther();
    error Pool__NoContributions();
    error Pool__NotEnoughFunds();

    ///////////////////
    //     Events    //
    ///////////////////

    event Contribution(address indexed contributor, uint256 amount);

    ///////////////////
    //     State     //
    ///////////////////

    uint256 private immutable i_end;
    uint256 private immutable i_goal;

    uint256 private s_totalCollected;
    mapping(address contributor => uint256 amount) private s_contributions;

    //////////////////////////////
    //     Constructor         //
    //////////////////////////////

    constructor(uint256 _interval, uint256 _goal) Ownable(msg.sender) {
        i_end = block.timestamp + _interval;
        i_goal = _goal;
    }

    //////////////////////////////
    //     Public functions     //
    //////////////////////////////
    /// @notice Contribute to the pool
    /// @dev This function allows users to contribute to the pool by sending ether.
    function contribute() public payable {
        if (block.timestamp >= i_end) {
            revert Pool__CollectIsFinished();
        }
        if (s_totalCollected >= i_goal) {
            revert Pool__GoalIsAlreadyReached();
        }

        s_totalCollected += msg.value;
        s_contributions[msg.sender] += msg.value;

        emit Contribution(msg.sender, msg.value);
    }
    /// @notice Withdraw funds from the pool
    /// @dev This function allows the owner to withdraw funds from the pool once the collection period is over.
    function withdraw() public onlyOwner {
        if (block.timestamp < i_end || s_totalCollected < i_goal) {
            revert Pool__CollectIsNotFinished();
        }

        uint256 amount = address(this).balance;
        (bool success,) = payable(msg.sender).call{value: amount}("");
        s_contributions[msg.sender] = 0;

        if (!success) {
            revert Pool__FailedToSendEther();
        }
    }
    /////// /////////////////////
    //   External functions   //
    ////////////////////////////
    /// @notice Refund the contribution
    /// @dev This function allows users to refund their contribution if the collection period is over and the goal is not reached.
    function refund() external {
        if (block.timestamp < i_end) {
            revert Pool__CollectIsNotFinished();
        }
        if (s_totalCollected >= i_goal) {
            revert Pool__GoalIsAlreadyReached();
        }
        if (s_contributions[msg.sender] == 0) {
            revert Pool__NoContributions();
        }
        uint256 amount = s_contributions[msg.sender];
        s_totalCollected -= amount;
        (bool success,) = payable(msg.sender).call{value: amount}("");
        s_contributions[msg.sender] = 0;
        if (!success) {
            revert Pool__FailedToSendEther();
        }
    }
    //////////////////////////////
    // External view functions  //
    //////////////////////////////

    function getOwner() external view returns (address) {
        return owner();
    }

    function getEnd() external view returns (uint256) {
        return i_end;
    }

    function getGoal() external view returns (uint256) {
        return i_goal;
    }

    function getTotalCollected() external view returns (uint256) {
        return s_totalCollected;
    }

    function getContribution(address user) external view returns (uint256) {
        return s_contributions[user];
    }
}
