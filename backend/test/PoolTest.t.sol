// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Pool} from "../src/Pool.sol";

contract PoolTest is Test {
    Pool private pool;
    address private OWNER = makeAddr("owner");
    address private USER1 = makeAddr("user1");
    address private USER2 = makeAddr("user2");

    function setUp() public {
        pool = new Pool(1 weeks, 10 ether);
    }

    function testContribute() public {
        vm.deal(USER1, 5 ether);
        vm.prank(USER1);
        pool.contribute{value: 5 ether}();
        assertEq(pool.getTotalCollected(), 5 ether);
        assertEq(pool.getContribution(USER1), 5 ether);
    }

    function testWithdraw() public {
        vm.deal(USER1, 10 ether);
        console.log(USER1.balance);
        vm.prank(USER1);
        pool.contribute{value: 10 ether}();

        vm.warp(block.timestamp + 1 weeks);
        uint256 initialOwnerBalance = OWNER.balance;
        vm.prank(OWNER);
        pool.withdraw();
        console.log(OWNER.balance);
        assertEq(OWNER.balance, initialOwnerBalance + 10 ether);
    }

    function testRefund() public {
        vm.deal(USER1, 5 ether);
        vm.prank(USER1);
        pool.contribute{value: 5 ether}();

        vm.warp(block.timestamp + 1 weeks);
        vm.prank(USER1);
        pool.refund();
        assertEq(USER1.balance, 5 ether);
        assertEq(pool.getTotalCollected(), 0);
    }

    function testFailContributeAfterEnd() public {
        vm.warp(block.timestamp + 1 weeks);
        vm.deal(USER1, 1 ether);
        vm.expectRevert(Pool.Pool__CollectIsFinished.selector);
        vm.prank(USER1);
        pool.contribute{value: 1 ether}();
    }

    function testFailWithdrawBeforeEnd() public {
        vm.prank(OWNER);
        vm.expectRevert(Pool.Pool__CollectIsNotFinished.selector);
        pool.withdraw();
    }

    function testFailRefundBeforeEnd() public {
        vm.prank(USER1);
        vm.expectRevert(Pool.Pool__CollectIsNotFinished.selector);
        pool.refund();
    }

    function testFailRefundAfterGoalReached() public {
        vm.deal(USER1, 10 ether);
        vm.prank(USER1);
        pool.contribute{value: 10 ether}();

        vm.warp(block.timestamp + 1 weeks);

        vm.prank(USER1);
        vm.expectRevert(Pool.Pool__GoalIsAlreadyReached.selector);
        pool.refund();
    }
}
