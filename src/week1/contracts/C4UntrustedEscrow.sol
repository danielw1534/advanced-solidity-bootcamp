// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "forge-std/console.sol";

/// Untrusted escrow. Create a contract where a depositor can put an arbitrary ERC20
/// token into a contract and a withdrawer can withdraw it 3 days later. Based on your readings above, what issues do
/// you
/// need to defend against? Create the safest version of this that you can while guarding against issues that you cannot
/// control. Does your contract handle fee-on transfer tokens or non-standard ERC20 tokens.
/// @author Question: How would this have been more efficient w/ a hash mapping?

/// @title UntrustedEscrow
contract C4UntrustedEscrowToken is ERC20 {
    /// @dev Mock ERC20 token.
    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, 100 ether);
    }
}

contract C4UntrustedEscrow {
    // =============================================================
    //                        STRUCTURES
    // =============================================================

    struct Transaction {
        address depositor;
        address withdrawer;
        uint256 amount;
        uint256 timestamp;
        bool completed;
    }
    // =============================================================
    //                         STORAGE
    // =============================================================

    IERC20 public _token;
    uint256 deposit_count;
    mapping(address => mapping(uint256 => Transaction)) public transactionsForAddress;

    mapping(bytes32 => Transaction) public transactionsForHash;

    // =============================================================
    //                          EVENTS
    // =============================================================

    event DepositEscrow(
        address indexed depositor,
        address indexed withdrawer,
        uint256 indexed deposit_count,
        uint256 amount,
        uint256 timestamp
    );

    // =============================================================
    //                          ERRORS
    // =============================================================

    // NOTE: Errors have no parameters for gas purposes.
    // Also, if you hit an error, you already know what function params you passed in.

    /// @dev The transaction data cannot be empty.
    error TransactionDataCannotBeEmpty();

    /// @dev The depositor cannot be the withdrawer.
    error DepositorCantBeWithdrawer();

    /// @dev Escrow amount cannot be equal to 0.
    error EscrowAmountCannotBeEqualToZero();

    /// @dev Approve ERC20 token deposit failed.
    error ApproveERC20TokenDepositFailed();

    /// @dev 3 day TimeLock has not passed yet.
    error TimeLockNotPassed();

    /// @dev Withdrawer cannot be zero address.
    error WithdrawerCannotBeZeroAddress();

    /// @dev Insufficient balance.
    error InsufficientBalance();

    /// @dev Withdrawal already completed.
    error WithdrawalAlreadyCompleted();

    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor(address ERC20Address) {
        _token = IERC20(ERC20Address);
        deposit_count = 0;
    }

    function getTransaction(
        address withdrawer_add,
        uint256 deposit_number
    )
        external
        view
        returns (Transaction memory)
    {
        return transactionsForAddress[withdrawer_add][deposit_number];
    }

    function depositEscrow(uint256 amount, address withdrawer) external {
        if (amount == 0) revert EscrowAmountCannotBeEqualToZero();
        if (withdrawer == address(0)) revert WithdrawerCannotBeZeroAddress();
        if (_token.balanceOf(msg.sender) < amount) revert InsufficientBalance();
        SafeERC20.safeTransferFrom(_token, msg.sender, address(this), amount);
        uint256 blockTimestamp = block.timestamp;
        emit DepositEscrow(msg.sender, withdrawer, deposit_count, amount, block.timestamp);
        transactionsForAddress[withdrawer][deposit_count] =
            Transaction(msg.sender, withdrawer, amount, blockTimestamp, false);
        deposit_count++;
    }

    function withdrawalEscrow(uint256 deposit_number) external {
        if (transactionsForAddress[msg.sender][deposit_number].completed == true) revert WithdrawalAlreadyCompleted();
        if (
            transactionsForAddress[msg.sender][deposit_number].depositor == address(0)
                || transactionsForAddress[msg.sender][deposit_number].withdrawer == address(0)
                || transactionsForAddress[msg.sender][deposit_number].timestamp == 0
        ) revert TransactionDataCannotBeEmpty();
        if (transactionsForAddress[msg.sender][deposit_number].withdrawer != msg.sender) {
            revert DepositorCantBeWithdrawer();
        }
        uint256 currentTime = block.timestamp;
        if (currentTime - transactionsForAddress[msg.sender][deposit_number].timestamp < 3 days) {
            revert TimeLockNotPassed();
        }
        SafeERC20.safeTransfer(_token, msg.sender, transactionsForAddress[msg.sender][deposit_number].amount);
        transactionsForAddress[msg.sender][deposit_number].completed = true;
    }
}
