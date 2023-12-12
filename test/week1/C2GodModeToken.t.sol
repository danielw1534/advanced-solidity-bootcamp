// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Test } from "forge-std/Test.sol";
import "forge-std/console.sol";
import { C2GodModeToken } from "../../src/week1/contracts/C2GodModeToken.sol";
import { DeployC2GodModeToken } from "../../script/week1/DeployC2GodModeToken.s.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363.sol";

contract C2GodModeTokenTest is Test {
    // =============================================================
    //                         STORAGE
    // =============================================================

    address public immutable ADMIN;
    address public immutable OWNER;

    C2GodModeToken public godModeToken;

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
    }

    function setUp() public {
        DeployC2GodModeToken deployGodModeToken = new DeployC2GodModeToken();
        deployGodModeToken.run();
        godModeToken = deployGodModeToken.godModeToken();
    }

    // =============================================================
    //                         TEST CASES
    // =============================================================
    /// @dev Test that admin can send token to any address;

    /// @dev Test that non-admin cannot send token to any address;
}
