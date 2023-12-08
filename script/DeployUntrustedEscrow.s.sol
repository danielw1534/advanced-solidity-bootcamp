// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { TimelockToken, UntrustedEscrow } from "../src/week-1/UntrustedEscrow.sol";

import "forge-std/Script.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployUntrustedEscrow is Script {
    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);
        TimelockToken tokenTimeLock = new TimelockToken("TokenTimelock", "TT");
        UntrustedEscrow untrustedEscrow = new UntrustedEscrow(address(tokenTimeLock));

        vm.stopBroadcast();
    }
}
