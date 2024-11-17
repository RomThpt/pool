// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Pool} from "../src/Pool.sol";

contract PoolTest is Test {
    Pool private pool;
    address private OWNER = makeAddr("owner");
    address private USER1 = makeAddr("user1");
    address private USER2 = makeAddr("user2");

    function setUp() public {
        vm.startPrank(OWNER);
        pool = new Pool(1 weeks, 10 ether);
        vm.stopPrank();
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
        vm.prank(USER1);
        pool.contribute{value: 10 ether}();

        vm.warp(block.timestamp + 1 weeks);
        vm.prank(OWNER);
        pool.withdraw();
        assertEq(address(OWNER).balance, 10 ether);
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
        vm.prank(USER1);
        pool.contribute{value: 1 ether}();
    }

    function testFailWithdrawBeforeEnd() public {
        vm.prank(OWNER);
        pool.withdraw();
    }

    function testFailRefundBeforeEnd() public {
        vm.prank(USER1);
        pool.refund();
    }

    function testFailRefundAfterGoalReached() public {
        vm.deal(USER1, 10 ether);
        vm.prank(USER1);
        pool.contribute{value: 10 ether}();

        vm.warp(block.timestamp + 1 weeks);
        vm.prank(USER1);
        pool.refund();
    }
}
