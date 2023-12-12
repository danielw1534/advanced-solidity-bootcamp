// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Test } from "forge-std/Test.sol";
import "forge-std/console.sol";
import { C4UntrustedEscrow, C4UntrustedEscrowToken } from "../../src/week1/contracts/C4UntrustedEscrow.sol";
import { DeployC4UntrustedEscrow } from "../../script/week1/DeployC4UntrustedEscrow.s.sol";

contract C4UntrustedEscrowTest is Test {
    // =============================================================
    //                         STORAGE
    // =============================================================

    address public immutable ADMIN;
    address public immutable OWNER;
    address public immutable PUBLIC_DEPOSITOR;
    address public immutable PUBLIC_DEPOSITOR_2;
    address public immutable PUBLIC_WITHDRAWER;
    address public immutable PUBLIC_WITHDRAWER_2;
    uint256 public immutable initialDeposit = 0.1 ether;
    C4UntrustedEscrow public untrustedEscrowWithoutDelay;
    C4UntrustedEscrow public untrustedEscrowWithDelay;
    C4UntrustedEscrowToken public untrustedEscrowToken;

    // =============================================================
    //                          EVENTS
    // =============================================================

    event DepositEscrow(
        address indexed depositor,
        address indexed withdrawer,
        uint256 indexed deposit_count,
        uint256 amount,
        uint256 timestamp
    );

    // =============================================================
    //                          ERRORS
    // =============================================================

    // NOTE: Errors have no parameters for gas purposes.
    // Also, if you hit an error, you already know what function params you passed in.

    error TimeLockNotPassed();

    error WithdrawalAlreadyCompleted();

    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor() {
        OWNER = address(this);
        ADMIN = vm.addr(0x01);
        PUBLIC_DEPOSITOR = vm.addr(0x02);
        PUBLIC_DEPOSITOR_2 = vm.addr(0x03);
        PUBLIC_WITHDRAWER = vm.addr(0x04);
        PUBLIC_WITHDRAWER_2 = vm.addr(0x05);
    }

    modifier startAtPresentDay() {
        vm.warp(1_680_616_584);
        _;
    }

    function setUp() public {
        DeployC4UntrustedEscrow deployUntrustedEscrow = new DeployC4UntrustedEscrow();
        deployUntrustedEscrow.run();
        untrustedEscrowToken = deployUntrustedEscrow.untrustedEscrowToken();
        untrustedEscrowWithoutDelay = new C4UntrustedEscrow(address(untrustedEscrowToken));
        untrustedEscrowWithDelay = new C4UntrustedEscrow(address(untrustedEscrowToken));
    }

    function test_DepositEscrow() public {
        vm.startBroadcast(PUBLIC_DEPOSITOR);
        deal(address(untrustedEscrowToken), PUBLIC_DEPOSITOR, 0.1 ether);
        uint256 amount = 0.1 ether;
        untrustedEscrowToken.approve(address(untrustedEscrowWithoutDelay), amount);
        uint256 deposit_count = 0;
        vm.expectEmit();
        emit DepositEscrow(PUBLIC_DEPOSITOR, PUBLIC_WITHDRAWER, deposit_count, amount, block.timestamp);
        untrustedEscrowWithoutDelay.depositEscrow(0.1 ether, PUBLIC_WITHDRAWER);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithoutDelay)), 0.1 ether);
        vm.stopBroadcast();
    }

    function test_WithdrawalEscrowRevertsWithoutDelay() public {
        vm.startBroadcast(PUBLIC_DEPOSITOR);
        deal(address(untrustedEscrowToken), PUBLIC_DEPOSITOR, 0.1 ether);
        uint256 amount = 0.1 ether;
        uint256 deposit_count = 0;
        untrustedEscrowToken.approve(address(untrustedEscrowWithoutDelay), amount);
        untrustedEscrowWithoutDelay.depositEscrow(0.1 ether, PUBLIC_WITHDRAWER);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithoutDelay)), 0.1 ether);
        vm.stopBroadcast();
        vm.startBroadcast(PUBLIC_WITHDRAWER);
        untrustedEscrowToken.approve(address(untrustedEscrowWithoutDelay), amount);
        vm.expectRevert(TimeLockNotPassed.selector);
        untrustedEscrowWithoutDelay.withdrawalEscrow(deposit_count);
        vm.stopBroadcast();
    }

    function test_WithdrawalEscrow_DoesntRevertAfterDelay() public startAtPresentDay {
        /// @dev Start deposit for test_WithdrawalEscrow_RevertsAfterDelay
        vm.startBroadcast(PUBLIC_DEPOSITOR_2);
        deal(address(untrustedEscrowToken), PUBLIC_DEPOSITOR_2, 0.1 ether);
        uint256 amount = 0.1 ether;
        untrustedEscrowToken.approve(address(untrustedEscrowWithDelay), amount);
        untrustedEscrowWithDelay.depositEscrow(0.1 ether, PUBLIC_WITHDRAWER_2);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithDelay)), 0.1 ether);
        vm.stopBroadcast();
        vm.startBroadcast(PUBLIC_WITHDRAWER_2);
        vm.warp(1_680_616_584 + 4 days);
        uint256 deposit_count = 0;
        untrustedEscrowToken.approve(address(untrustedEscrowWithDelay), amount);
        untrustedEscrowWithDelay.withdrawalEscrow(deposit_count);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithoutDelay)), 0 ether);
        assertEq(untrustedEscrowToken.balanceOf(PUBLIC_WITHDRAWER_2), 0.1 ether);
        assertEq(untrustedEscrowWithDelay.getTransaction(PUBLIC_WITHDRAWER_2, deposit_count).completed, true);
        vm.expectRevert(WithdrawalAlreadyCompleted.selector);
        untrustedEscrowWithDelay.withdrawalEscrow(deposit_count);
        vm.stopBroadcast();
    }
}
