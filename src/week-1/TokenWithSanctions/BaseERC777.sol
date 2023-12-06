// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "@openzeppelin/contracts-07/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts-07/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts-07/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts-07/introspection/ERC1820Implementer.sol";
import "@openzeppelin/contracts-07/introspection/IERC1820Registry.sol";

contract TestERC777 is ERC777 {
    constructor(uint256 initialSupply, address[] memory defaultOperators) ERC777("Gold", "GLD", defaultOperators) {
        _mint(msg.sender, initialSupply, "", "");
    }
}
