// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
// import "@openzeppelin/contracts/introspection/IERC1820Registry.sol";
// import "@openzeppelin/contracts/introspection/ERC1820Implementer.sol";
// import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";

// /**
//  * @title Simple777Token
//  * @dev Very simple ERC777 Token example, where all tokens are pre-assigned to the creator.
//  * Note they can later distribute these tokens as they wish using `transfer` and other
//  * `ERC20` or `ERC777` functions.
//  * Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/examples/SimpleToken.sol
//  */
// contract Simple777Token is ERC777, Ownable2Step {
//     /**
//      * @dev Constructor that gives msg.sender all of existing tokens.
//      */
//     constructor() public ERC777("Simple777Token", "S7", new address[](0)) {
//         _mint(msg.sender, 10_000 * 10 ** 18, "", "");
//     }
// }

// contract Simple777Sender is IERC777Sender, ERC1820Implementer, Ownable2Step {
//     bytes32 public constant TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
//     mapping(address => bool) public deniedSenders;
//     address public admin;

//     event DoneStuff(address operator, address from, address to, uint256 amount, bytes userData, bytes operatorData);
//     event SenderDenied(address indexed _sender);

//     constructor() public {
//         admin = msg.sender;
//     }

//     function senderFor(address account) public {
//         _registerInterfaceForAddress(TOKENS_SENDER_INTERFACE_HASH, account);
//     }

//     function tokensToSend(
//         address operator,
//         address from,
//         address to,
//         uint256 amount,
//         bytes calldata userData,
//         bytes calldata operatorData
//     )
//         external
//         override
//     {
//         // do stuff
//         require(!deniedSenders[from], "Simple777Sender: Sender is denied");
//         emit DoneStuff(operator, from, to, amount, userData, operatorData);
//     }
// }

// /**
//  * @title Simple777Recipient
//  * @dev Very simple ERC777 Recipient
//  */
// contract Simple777Recipient is IERC777Recipient {
//     IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
//     bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

//     IERC777 private _token;
//     mapping(address => bool) public deniedRecipients;

//     event DoneStuff(address operator, address from, address to, uint256 amount, bytes userData, bytes operatorData);
//     event RecipientDenied(address indexed _recipient);

//     constructor(address token) public {
//         _token = IERC777(token);

//         _erc1820.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
//     }

//     function updateRecipientDenyList(address recipient, bool isAllowed) public {
//         deniedRecipients[recipient] = isAllowed;
//         emit RecipientDenied(recipient);
//     }

//     function tokensReceived(
//         address operator,
//         address from,
//         address to,
//         uint256 amount,
//         bytes calldata userData,
//         bytes calldata operatorData
//     )
//         external
//         override
//     {
//         require(msg.sender == address(_token), "Simple777Recipient: Invalid token");
//         require(!deniedRecipients[to], "Simple777Recipient: Recipient is denied");

//         // do stuff
//         emit DoneStuff(operator, from, to, amount, userData, operatorData);
//     }
// }
