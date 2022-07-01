// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ZeppelinTestToken is ERC20 {
    constructor() ERC20("ZeppelinTestToken", "ZTT") {
        _mint(msg.sender, 1000000e18);
    }
}