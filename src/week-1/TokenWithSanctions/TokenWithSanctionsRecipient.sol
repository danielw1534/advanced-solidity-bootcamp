// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
// import "@openzeppelin/contracts/introspection/IERC1820Registry.sol";
// import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";

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
