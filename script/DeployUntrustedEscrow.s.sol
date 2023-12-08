// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { UntrustedEscrowTokenTimelock } from "../src/week-1/TokenWithSanctions/UntrustedEscrow.sol";

import "forge-std/Script.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployUntrustedEscrow is Script {
    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);
        UntrustedEscrowTokenTimelock tokenTimeLock = new UntrustedEscrowTokenTimelock();

        vm.stopBroadcast();
    }
}