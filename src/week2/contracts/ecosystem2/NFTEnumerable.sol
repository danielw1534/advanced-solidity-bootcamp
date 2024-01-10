// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./FindNFT.sol";

contract NftEnumerable is ERC721Enumerable, Ownable2Step {
    // =============================================================
    //                   STORAGE VARIABLES
    // =============================================================

    FindNFT public findNFT;

    // =============================================================
    //                      EVENTS
    // =============================================================

    event TokenMinted(address to, uint256 tokenId);

    // =============================================================
    //                   CONSTRUCTOR/INITIALIZER
    // =============================================================

    constructor(FindNFT _FindNFT, address _initialOwner) ERC721("NFTenumerable", "NET") Ownable(_initialOwner) {
        findNFT = _FindNFT;

        for (uint256 i = 1; i <= 20; i++) {
            _safeMint(_initialOwner, i);
            findNFT.updatePrimeMapping(i);
        }
    }

    // =============================================================
    //                   USER FUNCTIONS
    // =============================================================

    function safeMint(address to, uint256 tokenId) external onlyOwner {
        require(to != address(0), "Invalid address");
        _safeMint(to, tokenId);
        findNFT.updatePrimeMapping(tokenId);
        emit TokenMinted(to, tokenId);
    }
}
