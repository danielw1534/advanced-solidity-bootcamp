// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21 <0.9.0;

import { TestERC777 } from "../src/week-1/TokenWithSanctions/BaseERC777.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployERC777 is BaseScript {
    function run() public broadcast returns (Foo foo) {
        test = new TestERC777();
    }
}
