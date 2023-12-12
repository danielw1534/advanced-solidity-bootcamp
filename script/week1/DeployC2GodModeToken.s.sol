// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { C2GodModeToken } from "../../src/week1/contracts/C2GodModeToken.sol";

import "forge-std/Script.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployC2GodModeToken is Script {
    C2GodModeToken public godModeToken;

    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);
        godModeToken = new C2GodModeToken("GodModeToken", "GMT", msg.sender);
        vm.stopBroadcast();
    }
}
