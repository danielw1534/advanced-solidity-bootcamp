// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract FindNFT is Ownable2Step {
    IERC721Enumerable public NftEnumerable;

    // Mapping to store whether each tokenId is prime
    mapping(uint256 => bool) public isPrimeMapping;

    // Events
    event PrimeStatusUpdated(uint256 tokenId, bool isPrime);
    event PrimeTokenIdsSearchedCount(address user, uint256 count);

    constructor(IERC721Enumerable _NftEnumerable, address initialOwner_) Ownable(initialOwner_) {
        NftEnumerable = _NftEnumerable;
    }

    function primeTokenIDsCount(address user) external returns (uint256) {
        uint256 NftBalance = NftEnumerable.balanceOf(user);
        uint256 primeCounter = 0;
        uint256 tokenId;
        for (uint256 i = 0; i < NftBalance; i++) {
            tokenId = NftEnumerable.tokenOfOwnerByIndex(user, i);
            if (isPrimeMapping[tokenId]) {
                primeCounter += 1;
            }
        }
        emit PrimeTokenIdsSearchedCount(user, primeCounter);
        return primeCounter;
    }

    function updatePrimeMapping(uint256 tokenId) external onlyOwner {
        if (isPrimeMapping[tokenId] == false) {
            bool isPrime = checkPrime(tokenId);
            isPrimeMapping[tokenId] = isPrime;
            emit PrimeStatusUpdated(tokenId, isPrime); // Emit event
        }
    }

    function checkPrime(uint256 tokenId) internal pure returns (bool) {
        return (tokenId != 0 && tokenId != 1 && (tokenId == 2 || (tokenId % 2 != 0 && _isPrime(tokenId))));
    }

    function _isPrime(uint256 number) internal pure returns (bool) {
        /// @dev: values below 2 inclusive are handled above in checkPrime()
        if (number < 4) return false;
        /// @dev: Check if even outside the loop
        if (number % 2 == 0) return false;
        for (uint256 i = 3; i <= sqrt(number); i += 2) {
            /// @dev: Return false if not a divisor
            if (number % i == 0) return false;
        }
        /// @dev: If we get here we are prime
        return true;
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = (a + 1) / 2;
        uint256 b = a;
        while (c < b) {
            b = c;
            c = (a / c + c) / 2;
        }
        return b;
    }
}
