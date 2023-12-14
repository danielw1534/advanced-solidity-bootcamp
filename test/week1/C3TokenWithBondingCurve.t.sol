// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Test } from "forge-std/Test.sol";
import "forge-std/console.sol";
import { C3TokenWithBondingCurve } from "../../src/week1/contracts/C3TokenWithBondingCurve.sol";
import { DeployC3TokenWithBondingCurve } from "../../script/week1/DeployC3TokenWithBondingCurve.s.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363.sol";

contract C3TokenWithBondingCurveTest is Test {
    // =============================================================
    //                         STORAGE
    // =============================================================

    address public immutable ADMIN;
    address public immutable OWNER;
    address public immutable MINTER;
    address public immutable BURNER;
    address public wethAddress;

    C3TokenWithBondingCurve public tokenWithBondingCurve;

    // =============================================================
    //                          EVENTS
    // =============================================================

    // =============================================================
    //                          ERRORS
    // =============================================================

    // NOTE: Errors have no parameters for gas purposes.
    // Also, if you hit an error, you already know what function params you passed in.

    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor() {
        OWNER = address(this);
        ADMIN = vm.addr(0x01);
        MINTER = vm.addr(0x02);
        BURNER = vm.addr(0x03);
    }

    function setUp() public {
        DeployC3TokenWithBondingCurve deployTokenWithBondingCurve = new DeployC3TokenWithBondingCurve();
        deployTokenWithBondingCurve.run();
        tokenWithBondingCurve = deployTokenWithBondingCurve.tokenWithBondingCurve();
        wethAddress = address(deployTokenWithBondingCurve.erc1363Token());
    }

    // =============================================================
    //                         TEST CASES
    // =============================================================

    function test_purchaseTokens() public {
        vm.startBroadcast(MINTER);
        deal(MINTER, 100 ether);
        deal(address(wethAddress), MINTER, 10 ether);
        uint256 initialSupply = tokenWithBondingCurve.outstandingTokens();
        uint256 expectedPurchasableTokenCount = tokenWithBondingCurve.calculateMaxTokensPurchasable(10 ether);
        IERC20(wethAddress).approve(address(tokenWithBondingCurve), 10 ether);
        tokenWithBondingCurve.purchaseTokens(initialSupply, 10 ether);
        assertEq(IERC1363(wethAddress).balanceOf(address(tokenWithBondingCurve)), 10 ether);
        assertEq(tokenWithBondingCurve.balanceOf(MINTER), expectedPurchasableTokenCount);
        assertEq(tokenWithBondingCurve.outstandingTokens(), initialSupply + expectedPurchasableTokenCount);
        vm.stopBroadcast();
    }

    /// @dev Test that admin can send token to any address - currently failing;
    function test_sellTokens() private {
        vm.startBroadcast(MINTER);
        deal(MINTER, 100 ether);
        deal(address(wethAddress), MINTER, 10 ether);
        uint256 initialSupply = tokenWithBondingCurve.outstandingTokens();
        IERC20(wethAddress).approve(address(tokenWithBondingCurve), 10 ether);
        tokenWithBondingCurve.purchaseTokens(initialSupply, 10 ether);
        uint256 minterRemainingBalance = tokenWithBondingCurve.balanceOf(MINTER);
        uint256 amountRedeemable = tokenWithBondingCurve.calculateAmountRedeemable(minterRemainingBalance);
        console.log("minterRemainingBalance", minterRemainingBalance);
        console.log("amountRedeemable", amountRedeemable);
        IERC20(wethAddress).approve(address(tokenWithBondingCurve), amountRedeemable);
        tokenWithBondingCurve.sellTokens(minterRemainingBalance);
        assertEq(tokenWithBondingCurve.balanceOf(MINTER), 0);
        assertEq(tokenWithBondingCurve.outstandingTokens(), initialSupply);
        vm.stopBroadcast();
    }
}
