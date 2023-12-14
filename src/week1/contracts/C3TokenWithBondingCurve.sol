// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/interfaces/IERC1363.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

/// Token sale and buyback with bonding curve. The more tokens a user buys, the more expensive the token becomes. To
/// keep things simple, use a linear bonding curve. Consider the case someone might sandwhich attack a bonding curve.

/// @title TokenWithBondingCurve
contract C3TokenWithBondingCurve is ERC20, Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Math for uint256;

    uint256 public immutable initialPrice = 0.01 ether;
    uint256 public immutable curveSlope = 1;
    address public wethToken;

    /// @dev Necessary to prevent front-running.
    uint256 public outstandingTokens;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    /// @dev Amount must be greater than zero.
    error AmountMustBeGreaterThanZero();

    /// @dev Failed to transfer token.
    error FailedToTransferToken();

    /// @dev Initial supply has changed since the last purchase.
    error InitialSupplyHasChanged();

    /// @dev Insufficient balance.
    error InsufficientBalance();

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner_,
        uint256 totalSupply_,
        address exchangeToken_
    )
        Ownable(initialOwner_)
        ERC20(name_, symbol_)
    {
        wethToken = exchangeToken_;
        _mint(msg.sender, totalSupply_);
    }

    function calculatePriceFromSupply(
        uint256 largerTotalSupply,
        uint256 smallerTotalSupply
    )
        public
        pure
        returns (uint256)
    {
        uint256 largerTotalPricePerToken = calculatePrice(largerTotalSupply);
        uint256 smallerTotalPricePerToken = calculatePrice(smallerTotalSupply);
        /// @dev Calculate the price of a token given the initial and ending total supply.
        /// @dev The price is calculated using the formula:
        /// @dev price = initialPrice + 1/2(largerTotalSupply - smallerTotalSupply)((largerTotalPricePerToken -
        /// smallerTotalPricePerToken))
        uint256 totalPrice = (
            (initialPrice + initialPrice + (curveSlope * (largerTotalSupply - smallerTotalSupply)))
                * (largerTotalPricePerToken - smallerTotalPricePerToken)
        ) / 2;
        return totalPrice;
    }

    function sqrt(uint256 x) private pure returns (uint256) {
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    function calculateOutstandingTokens() external view returns (uint256) {
        return totalSupply() - balanceOf(address(this));
    }

    /// @param amount The value amount of tokens to be purchased.
    function calculateMaxTokensPurchasable(uint256 amount) public view returns (uint256) {
        uint256 initialTokenSupply = outstandingTokens;
        uint256 slope = curveSlope;
        // Function to calculate the value of x based on the given formula
        // x = (slope * y + sqrt(2 * slope * z + 1) - 1) / m
        require(slope != 0, "slope cannot be zero");

        uint256 part1 = slope * initialTokenSupply;
        uint256 part2 = sqrt(2 * slope * amount + 1);

        uint256 numerator = part1 + part2 - 1;
        uint256 x = numerator / slope;
        return x;
    }

    function calculateAmountRedeemable(uint256 amount) public view returns (uint256) {
        uint256 initialTokenSupply = outstandingTokens;
        uint256 slope = curveSlope;
        uint256 totalPrice = calculatePriceFromSupply(initialTokenSupply, initialTokenSupply - amount);
        // Function to calculate the value of y based on the given formula
        // y = (m * x + 1) / (slope * x + 1)
        require(slope != 0, "slope cannot be zero");

        uint256 part1 = 1 + slope * totalPrice;
        uint256 part2 = sqrt(1 + 2 * slope * totalPrice);

        uint256 numerator = part1 - part2;
        uint256 result = numerator / slope;

        return result;
    }

    function calculatePrice(uint256 tokenSupply) public pure returns (uint256) {
        return initialPrice + initialPrice * curveSlope * tokenSupply;
    }

    /// @dev Mint tokens to the msg.sender
    /// @param initialSupply The total outstanding tokens at time of purchase.
    /// @dev this should be external, since no internal functions are calling it
    /// @dev public functions 
    function purchaseTokens(uint256 initialSupply, uint256 depositAmount) external nonReentrant {
        uint256 amount = depositAmount;
        if (amount == 0) revert AmountMustBeGreaterThanZero();
        if (initialSupply != outstandingTokens) revert InitialSupplyHasChanged();
        bool success = IERC1363(wethToken).transferFrom(msg.sender, address(this), amount);

        if (!success) revert FailedToTransferToken();
        uint256 tokens = calculateMaxTokensPurchasable(amount);
        outstandingTokens += tokens;
        _batchMint(msg.sender, tokens);
    }

    function _batchMint(address from, uint256 amount) internal {
        if (amount == 0) revert AmountMustBeGreaterThanZero();
        _mint(from, amount);
    }

    function sellTokens(uint256 tokenAmount) external {
        uint256 amount = tokenAmount;
        if (amount == 0) revert AmountMustBeGreaterThanZero();
        if (amount > balanceOf(msg.sender)) revert InsufficientBalance();
        uint256 amountToReturn = calculateAmountRedeemable(amount);
        _burn(msg.sender, tokenAmount);
        /// @dev This doesn't do what I thought it did
        /// @dev This just says make sure the wethToken address has the transferFrom function
        /// @dev would be better to to a safeTransferFrom here
        IERC1363(wethToken).transferFrom(address(this), msg.sender, amountToReturn);
    }

    function onTransferReceived(
        address, /* operator */
        address from,
        uint256 amount,
        bytes calldata /*  data */
    )
        external
        returns (bytes4)
    {
        require(msg.sender == wethToken, "Only DAI accepted");
        _batchMint(from, amount);
        return IERC1363Receiver.onTransferReceived.selector;
    }
}
