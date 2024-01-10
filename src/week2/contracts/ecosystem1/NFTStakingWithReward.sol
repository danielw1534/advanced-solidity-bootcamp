// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IBasicStakingToken } from "./BasicStakingToken.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { MerkleTreeDiscountToken } from "./MerkleTreeDiscountToken.sol";

/// @title Staking rewards token
abstract contract NFTStakingWithReward is Ownable2Step, ReentrancyGuard, IERC721Receiver {
    struct DepositStruct {
        address originalOwner;
        uint256 depositTime;
    }

    // =============================================================
    //                   EVENTS
    // =============================================================

    event StakedNFT(address indexed staker, uint256 indexed tokenId);
    event UnstakedNFT(address indexed staker, uint256 indexed tokenId);
    event ClaimedRewards(address indexed staker, uint256 indexed tokenId, uint256 indexed rewards);
    // =============================================================
    //                   STORAGE VARIABLES
    // =============================================================

    IBasicStakingToken public BasicStakingTokenContract;
    IERC721 public merkleTreeDiscountTokenContract;

    mapping(uint256 => DepositStruct) deposits;
    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor(address initialOwner_, address _royaltyContract) Ownable(initialOwner_) {
        merkleTreeDiscountTokenContract = IERC721(_royaltyContract);
    }

    // =============================================================
    //                       USER FUNCTIONS
    // =============================================================
    function calculateRewards(uint256 depositTimestamp) internal view returns (uint256) {
        uint256 _timeSinceDeposit = block.timestamp - depositTimestamp;
        uint256 _calculatedRewards = _timeSinceDeposit * 10 ether / 1 days;
        return _calculatedRewards;
    }

    function stakeNFT(uint256 tokenId) external {
        require(merkleTreeDiscountTokenContract.ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        deposits[tokenId] = DepositStruct(msg.sender, block.timestamp);
        BasicStakingTokenContract.transferFrom(msg.sender, address(this), tokenId);
        emit StakedNFT(msg.sender, tokenId);
    }

    function unstakeNFT(uint256 tokenId) external {
        require(deposits[tokenId].originalOwner == msg.sender, "You are not the owner of this NFT");
        BasicStakingTokenContract.transferFrom(address(this), msg.sender, tokenId);
        emit UnstakedNFT(msg.sender, tokenId);
    }

    function claimRewards(uint256 tokenId) external {
        require(deposits[tokenId].originalOwner == msg.sender, "You are not the owner of this NFT");
        require(deposits[tokenId].depositTime != 0, "You have not staked this NFT");
        require(deposits[tokenId].depositTime + 1 days < block.timestamp, "You cannot claim rewards yet");
        uint256 _calculatedRewards = calculateRewards(deposits[tokenId].depositTime);
        BasicStakingTokenContract.mint(msg.sender, _calculatedRewards);
        emit ClaimedRewards(msg.sender, tokenId, _calculatedRewards);
    }
}
