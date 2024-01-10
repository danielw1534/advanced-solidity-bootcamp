// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


/// it can mint new ERC20 tokens and receive new ERC721 tokens
contract BasicStaking is ERC20, Ownable2Step, ReentrancyGuard {
    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor(
        uint256 initialSupply,
        address initialOwner_
    )
        Ownable(initialOwner_)
        ERC20("BasicStaking", "BST")
    {
        _mint(address(this), initialSupply);
    }

    // =============================================================
    //                       USER FUNCTIONS
    // =============================================================

    function stake(uint256 amount) external nonReentrant {
        _approve(msg.sender, address(this), amount);

        _transfer(msg.sender, address(this), amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        _transfer(address(this), msg.sender, amount);
    }

    function withdrawFunds (address to, uint256 amount) external onlyOwner {
        _transfer(address(this), to, amount);
    }
}
