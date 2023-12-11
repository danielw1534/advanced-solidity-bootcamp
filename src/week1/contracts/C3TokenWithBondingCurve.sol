// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// Token sale and buyback with bonding curve. The more tokens a user buys, the more expensive the token becomes. To
/// keep things simple, use a linear bonding curve. Consider the case someone might sandwhich attack a bonding curve.

/// @title TokenWithBondingCurve
contract C3TokenWithBondingCurve is ERC20, Ownable2Step, ReentrancyGuard {
    uint256 public immutable initialPrice = 0.01 ether;
    uint256 public immutable curveSlope = 1;

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner_
    )
        Ownable(initialOwner_)
        ERC20(name_, symbol_)
    { }

    function purchaseTokens() public payable nonReentrant {
        uint256 amount = msg.value;
        uint256 tokens = amount * 1e18;
        _mint(msg.sender, tokens);
    }

    function sellTokens() public payable {
        uint256 amount = msg.value;
        uint256 tokens = amount * 1e18;
        _burn(msg.sender, tokens);
        payable(msg.sender).transfer(amount);
    }
}
