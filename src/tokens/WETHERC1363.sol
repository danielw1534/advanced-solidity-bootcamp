// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1363 } from "./ERC1363.sol";

contract WETHERC1363 is ERC1363 {
    constructor() ERC20("WETH", "WETH") {
        _mint(msg.sender, 1_000_000);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
