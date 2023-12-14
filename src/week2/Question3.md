## Revisit the solidity events tutorial. How can OpenSea quickly determine which NFTs an address owns if most NFTs don’t use ERC721 enumerable? Explain how you would accomplish this if you were creating an NFT marketplace

You would query every block to get a historical list (that's updated with each new block) for all ERC721 contracts created and ERC1155's. Then, you listen for `Transfer` events for any contracts you've already previously indexed. You need to keep this in a centralized database or else query time will be too long.
