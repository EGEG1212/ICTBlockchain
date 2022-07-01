// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ZeppelinTestToken is ERC721 {
    constructor() ERC721("ZeppelinTestToken", "ZTT") {
    }

    function mint(uint256 tokenID, bytes memory data) public returns (bool){
        _safeMint(msg.sender, tokenID, data);
        return true;
    }
}