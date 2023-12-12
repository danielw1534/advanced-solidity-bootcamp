// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { C3TokenWithBondingCurve } from "../../src/week1/contracts/C3TokenWithBondingCurve.sol";

import "forge-std/Script.sol";
import { WETHERC1363 } from "../../src/tokens/WethERC1363.sol";
import { ERC1363 } from "../../src/tokens/ERC1363.sol";
/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting

contract DeployC3TokenWithBondingCurve is Script {
    C3TokenWithBondingCurve public tokenWithBondingCurve;
    ERC1363 public erc1363Token;

    function run() public {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);
        erc1363Token = new WETHERC1363();
        tokenWithBondingCurve =
            new C3TokenWithBondingCurve("TokenWithBondingCurve", "TBC", msg.sender, 1000 ether, address(erc1363Token) );
        vm.stopBroadcast();
    }
}
