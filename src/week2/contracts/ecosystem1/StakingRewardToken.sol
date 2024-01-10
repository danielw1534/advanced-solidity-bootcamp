// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Staking rewards token
contract StakingRewardToken is ERC20, Ownable2Step, ReentrancyGuard {
    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor(
        uint256 initialSupply,
        address initialOwner_
    )
        Ownable(initialOwner_)
        ERC20("StakingRewardToken", "SRT")
    {
        _mint(address(this), initialSupply);
    }

    // =============================================================
    //                       USER FUNCTIONS
    // =============================================================
}
