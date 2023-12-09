// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title TokenWithBondingCurve
contract C3TokenWithBondingCurve is ERC20, Ownable2Step, ReentrancyGuard {
    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner_
    )
        Ownable(initialOwner_)
        ERC20(name_, symbol_)
    { }

    function _mint(address to, uint256 amount) internal virtual override {
        require(amount <= 1 * 1e18, "TokenSaleBuybackToken: amount exceeds 1");
        /// @dev question: to.call vs. msg.value()?

        // rounding
        // slippage

        to.call{ value: totalSupply() * 2 }("");
        _mint(to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual override {
        _burn(from, amount);
    }
}
