// // SPDX-License-Identifier: MIT
// pragma solidity =0.8.4;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.1/contracts/token/ERC777/ERC777.sol";

// contract TokenWithSanctionsV2 is IERC777Recipient {
//     mapping(address => uint256) public balances;
//     ERC777 my_erc777;
//     mapping(address => bool) public deniedRecipients;
//     mapping(address => bool) public deniedSenders;

//     modifier onlyOwner() {
//         require(msg.sender == owner);
//         _;
//     }

//     IERC1820Registry private registry1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

//     event RecipientDenied(address indexed _recipient);
//     event SenderDenied(address indexed _sender);
//     event Deposit(address indexed _from, uint256 _value);
//     event Withdrawal(address indexed _to, uint256 _value);

//     constructor(address my_erc777_address) {
//         admin = msg.sender;
//         registry1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
//         my_erc777 = ERC777(my_erc777_address);
//     }

//     function addToRecipientDenyList(address recipient) public onlyOwner {
//         recipientDenyList[recipient] = true;
//         emit RecipientDenied(recipient);
//     }

//     function addToSenderDenyList(address sender) public onlyOwner {
//         senderDenyList[sender] = true;
//         emit SenderDenied(sender);
//     }

//     //ERC777 Recipient Hook
//     function tokensReceived(
//         address operator,
//         address from,
//         address to,
//         uint256 amount,
//         bytes calldata data,
//         bytes calldata operatorData
//     )
//         external
//         override
//     {
//         require(!recipientDenyList[to], "Recipient is denied");
//         require(!senderDenyList[from], "Sender is denied");
//         balances[to] += amount;
//         emit Deposit(from, amount);
//     }

//     //ERC777 Sender Hook
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
//         require(!recipientDenyList[to], "Recipient is denied");
//         require(!senderDenyList[from], "Sender is denied");
//         balances[from] -= amount;
//         emit Withdrawal(to, amount);
//     }

//     fallback() external payable { }
// }
