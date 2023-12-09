// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "@openzeppelin/contracts-07/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts-07/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts-07/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts-07/introspection/ERC1820Implementer.sol";
import "@openzeppelin/contracts-07/introspection/IERC1820Registry.sol";

/// @title ERC777 with sanctions
contract C1TokenWithSanctions is ERC777 {
    constructor(uint256 initialSupply) ERC777("Gold", "GLD", new address[](0)) {
        _mint(msg.sender, initialSupply, "", "");
    }
}

/// @title ERC777 with sanctions
contract UsingC1TokenWithSanctions is IERC777Recipient, IERC777Sender, ERC1820Implementer {
    ERC777 public token;
    IERC1820Registry public registry = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    address public admin;
    mapping(address => bool) public deniedSenders;
    mapping(address => bool) public deniedRecipients;

    // keccak256('ERC777TokensRecipient')
    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    //   keccak256("ERC777TokensSender")
    bytes32 private constant TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    mapping(address => uint256) private _balances;

    constructor() {
        token = new C1TokenWithSanctions(100 ether);
        token.transfer(msg.sender, 100 ether);
        admin = msg.sender;

        registry.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
        registry.setInterfaceImplementer(address(this), TOKENS_SENDER_INTERFACE_HASH, address(this));
    }

    function updateRecipientDenyList(address recipient, bool isAllowed) public onlyAdmin {
        deniedRecipients[recipient] = isAllowed;
    }

    function updateSenderDenyList(address sender, bool isAllowed) public onlyAdmin {
        deniedSenders[sender] = isAllowed;
    }

    function tokensReceived(
        address, /*operator*/
        address from,
        address, /*to*/
        uint256 amount,
        bytes calldata, /*userData*/
        bytes calldata /*operatorData*/
    )
        external
        override
    {
        require(!deniedRecipients[from], "Simple777Recipient: Sender is denied");
        _balances[from] += amount;
    }

    function tokensToSend(
        address, /*operator*/
        address from,
        address, /*to*/
        uint256 amount,
        bytes calldata, /*userData*/
        bytes calldata /*operatorData*/
    )
        external
        override
    {
        require(!deniedSenders[from], "Simple777Sender: Sender is denied");
        _balances[from] -= amount;
    }
}
