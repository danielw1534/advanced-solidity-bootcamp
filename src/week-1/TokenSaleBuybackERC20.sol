// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title TokenSaleBuybackToken
contract TokenSaleBuybackToken is ERC20, Ownable2Step {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) { }

    function mint(address to, uint256 amount) external override {
        require(amount <= 1 * 1e18, "TokenSaleBuybackToken: amount exceeds 1");
        /// @dev question: to.call vs. msg.value()?
        to.call{ value: totalSupply() * 2 }("");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external override {
        _burn(from, amount);
    }
}
