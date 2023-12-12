// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { C4UntrustedEscrowToken, C4UntrustedEscrow } from "../../src/week1/contracts/C4UntrustedEscrow.sol";

import "forge-std/Script.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployC4UntrustedEscrow is Script {
    C4UntrustedEscrowToken public untrustedEscrowToken;
    C4UntrustedEscrow public untrustedEscrow;

    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);
        untrustedEscrowToken = new C4UntrustedEscrowToken("UntrustedEscrowToken", "UET");
        untrustedEscrow = new C4UntrustedEscrow(address(untrustedEscrowToken));
        vm.stopBroadcast();
    }
}
