// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;

import { Test, console2 } from "forge-std/Test.sol";
import { C1TokenWithSanctions } from "../../src/week1/contracts/C1TokenWithSanctions.sol";

contract C1TokenWithSanctionsTest is Test {

    C1TokenWithSanctions public tokenWithSanctions;

    function setUp() private {
        tokenWithSanctions = new C1TokenWithSanctions(100 ether);
        // tokenWithSanctions.setNumber(0);
    }

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    function testFuzz_SetNumber(uint256 x) private {
        //     counter.setNumber(x);
        //     assertEq(counter.number(), x);
    }
}
