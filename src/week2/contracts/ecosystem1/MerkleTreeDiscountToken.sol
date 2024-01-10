pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleTreeDiscountToken is Ownable, ERC721Royalty {
    // This is a packed array of booleans.
    /// @dev Still to do: do a proper bitmap implementation
    /*///////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 private constant MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256[3] arr = [MAX_INT, MAX_INT, MAX_INT];
    mapping(uint256 => uint256) private claimedBitMap;
    uint256 public constant MAX_SUPPLY = 1000; // Maximum supply of NFTs
    uint256 public totalSupply; // Current supply of NFTs
    address public immutable token;
    bytes32 public immutable merkleRoot = 0x922c30c4db7884b9f10737925f272cb43ad59bd414e961338e4e77217463e56b;
    uint256 public mintPrice = 0.01 ether;
    uint256 public discountPrice = 0.005 ether;

    mapping(address => bool) public discountListClaimed;

    /*///////////////////////////////////////////////////////////////
                            ERROR MESSAGES
    //////////////////////////////////////////////////////////////*/
    error MaxSupplyReached();
    /*///////////////////////////////////////////////////////////////
                        CONSTRUCTOR/INITIALIZER
    //////////////////////////////////////////////////////////////*/

    constructor(address initialOwner) ERC721("MerkleTreeDiscountToken", "MTDT") Ownable(initialOwner) {
        _setDefaultRoyalty(msg.sender, 250);
    }

    /*///////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function safeMint(address to) public payable onlyOwner {
        if (totalSupply >= MAX_SUPPLY) revert MaxSupplyReached();
        require(msg.value >= mintPrice, "Not enough ETH");
        totalSupply++;
        uint256 tokenId = totalSupply;
        _safeMint(to, tokenId);
    }

    function discountListMint(bytes32[] calldata _merkleProof, uint256 tokenId) external payable {
        require(tokenId < arr.length*256, "Invalid token ID");
        uint256 storageOffset = tokenId / 256;
        uint256 offsetWithin256 = tokenId % 256;
        uint256 storedBit = (arr[storageOffset] >> offsetWithin256) & uint256(1);
        require(storedBit == 1, "Already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof");
        require(msg.value >= discountPrice, "Not enough ETH");
        arr[storageOffset] &= ~(uint256(1) << offsetWithin256);
        totalSupply++;
        _safeMint(msg.sender, tokenId);
    }
}
