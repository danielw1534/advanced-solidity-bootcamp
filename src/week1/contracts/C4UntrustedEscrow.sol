// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Untrusted escrow. Create a contract where a buyer can put an arbitrary ERC20
// token into a contract and a seller can withdraw it 3 days later. Based on your readings above, what issues do you
// need to defend against? Create the safest version of this that you can while guarding against issues that you cannot
// control. Does your contract handle fee-on transfer tokens or non-standard ERC20 tokens.

/// @title UntrustedEscrow
contract C4UntrustedEscrowToken is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, 10_000 * 10 ** decimals());
    }
}

contract C4UntrustedEscrow {
    IERC20 public _token;
    uint256 deposit_count;
    mapping(bytes32 => uint256) balances;
    mapping(bytes32 => uint256) timestamps;

    constructor(address ERC20Address) {
        _token = IERC20(ERC20Address);
    }

    function depositEscrow(bytes32 tx_hash, uint256 amount) external {
        // Transaction hash cannot be empty
        require(tx_hash[0] != 0, "Transaction hash cannot be empty!");
        // Escrow amount cannot be equal to 0
        require(amount != 0, "Escrow amount cannot be equal to 0.");
        // Transaction hash is already in use
        require(balances[tx_hash] == 0, "Unique hash conflict, hash is already in use.");
        // Transfer ERC20 token from sender to this contract
        require(_token.transferFrom(msg.sender, address(this), amount), "Transfer to escrow failed!");
        balances[tx_hash] = amount;
        timestamps[tx_hash] = block.timestamp;
        deposit_count++;
    }

    function getHash(uint256 amount) public view returns (bytes32 result) {
        return keccak256(abi.encodePacked(msg.sender, deposit_count, amount));
    }

    function withdrawalEscrow(bytes32 trx_hash) external {
        // Transaction hash cannot be empty
        require(trx_hash[0] != 0, "Transaction hash cannot be empty!");
        // Check if trx_hash exists in balances
        require(balances[trx_hash] != 0, "Escrow with transaction hash doesn't exist.");
        // Check if 3 days have passed
        require(block.timestamp - timestamps[trx_hash] >= 3 days, "3 days have not passed yet.");
        // Transfer escrow to sender
        SafeERC20.safeTransfer(_token, msg.sender, balances[trx_hash]);
        // If all is done, status is amounted to 0
        balances[trx_hash] = 0;
    }
}
