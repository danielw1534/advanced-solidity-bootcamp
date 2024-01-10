// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IBasicStakingToken is IERC20, IAccessControl {
    function mint(address to, uint256 amount) external;
}

/// it can mint new ERC20 tokens and receive new ERC721 tokens
abstract contract BasicStakingToken is ERC20, Ownable2Step, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor(uint256 initialSupply, address initialOwner_) Ownable(initialOwner_) ERC20("BasicStaking", "BST") {
        require(initialOwner_ != address(0), "Invalid address");
        _setupRole(DEFAULT_ADMIN_ROLE, initialOwner_);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, MINTER_ROLE);
        _setupRole(MINTER_ROLE, initialOwner_);
    }

    // =============================================================
    //                       USER FUNCTIONS
    // =============================================================

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(to != address(0), "Invalid address");
        _mint(to, amount);
    }

    function withdraw(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Invalid address");
        _transfer(address(this), to, amount);
    }
}
