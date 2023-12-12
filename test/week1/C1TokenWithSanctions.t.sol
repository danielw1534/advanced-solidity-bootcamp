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

    // =============================================================
    //                         TEST CASES
    // =============================================================
    /// @dev Test that admin can ban address from receiving token;

    /// @dev Test that admin can ban address from sending token;

    /// @dev Test that non-admin cannot ban address from receiving token;

    /// @dev Test that non-banned address can receive & send token;
}
