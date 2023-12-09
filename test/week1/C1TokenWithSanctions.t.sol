// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Test, console2 } from "forge-std/Test.sol";
import { C1TokenWithSanctions } from "../../src/week1/contracts/C1TokenWithSanctions.sol";

contract C1TokenWithSanctionsTest is Test {
    C1TokenWithSanctions public tokenWithSanctions;

    function setUp() public {
        tokenWithSanctions = new C1TokenWithSanctions();
        // tokenWithSanctions.setNumber(0);
    }

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
