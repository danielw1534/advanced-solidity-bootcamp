// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
// import "@openzeppelin/contracts/introspection/IERC1820Registry.sol";
// import "@openzeppelin/contracts/introspection/ERC1820Implementer.sol";
// import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";

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
