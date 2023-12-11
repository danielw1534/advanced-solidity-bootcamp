// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Test } from "forge-std/Test.sol";
import "forge-std/console.sol";
import { C4UntrustedEscrow, C4UntrustedEscrowToken } from "../../src/week1/contracts/C4UntrustedEscrow.sol";
import { DeployUntrustedEscrow } from "../../script/week1/DeployUntrustedEscrow.s.sol";

contract C4UntrustedEscrowTest is Test {
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

    error TimeLockNotPassed();

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
        DeployUntrustedEscrow deployUntrustedEscrow = new DeployUntrustedEscrow();
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
        untrustedEscrowWithoutDelay.depositEscrow(0.1 ether, PUBLIC_WITHDRAWER);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithoutDelay)), 0.1 ether);
        vm.stopBroadcast();
    }

    function test_WithdrawalEscrowRevertsWithoutDelay() public {
        vm.startPrank(PUBLIC_DEPOSITOR);
        deal(address(untrustedEscrowToken), PUBLIC_DEPOSITOR, 0.1 ether);
        uint256 amount = 0.1 ether;
        uint256 deposit_count = 0;
        untrustedEscrowToken.approve(address(untrustedEscrowWithoutDelay), amount);
        untrustedEscrowWithoutDelay.depositEscrow(0.1 ether, PUBLIC_WITHDRAWER);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithoutDelay)), 0.1 ether);
        vm.stopPrank();
        vm.startPrank(PUBLIC_WITHDRAWER);
        untrustedEscrowToken.approve(address(untrustedEscrowWithoutDelay), amount);
        vm.expectRevert(TimeLockNotPassed.selector);
        untrustedEscrowWithoutDelay.withdrawalEscrow(deposit_count);
        vm.stopPrank();
    }

    function test_WithdrawalEscrow_DoesntRevertAfterDelay() public startAtPresentDay {
        /// @dev Start deposit for test_WithdrawalEscrow_RevertsAfterDelay
        vm.startPrank(PUBLIC_DEPOSITOR_2);
        deal(address(untrustedEscrowToken), PUBLIC_DEPOSITOR_2, 0.1 ether);
        uint256 amount = 0.1 ether;
        untrustedEscrowToken.approve(address(untrustedEscrowWithDelay), amount);
        untrustedEscrowWithDelay.depositEscrow(0.1 ether, PUBLIC_WITHDRAWER_2);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithDelay)), 0.1 ether);
        vm.stopPrank();
        vm.startPrank(PUBLIC_WITHDRAWER_2);
        vm.warp(1_680_616_584 + 4 days);
        uint256 deposit_count = 0;
        untrustedEscrowToken.approve(address(untrustedEscrowWithDelay), amount);
        untrustedEscrowWithDelay.withdrawalEscrow(deposit_count);
        assertEq(untrustedEscrowToken.balanceOf(address(untrustedEscrowWithoutDelay)), 0 ether);
        assertEq(untrustedEscrowToken.balanceOf(PUBLIC_WITHDRAWER_2), 0.1 ether);
        assertEq(untrustedEscrowWithDelay.getTransaction(PUBLIC_WITHDRAWER_2, deposit_count).completed, true);
        vm.stopPrank();
    }

    // test if the contract can handle fee-on transfer tokens

    // test if the contract can handle non-standard ERC20 tokens

    // test withdrawal reverts before 3 days

    // test to make sure you can't withdraw twice

    // test to make sure you can't withdraw more than what is set aside for you
}
