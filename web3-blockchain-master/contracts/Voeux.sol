// SPDX-License-Identifier: GPL-3.0 and MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DappToken is ERC20 {
    constructor() ERC20("V TOKEN", "V") {
        _mint(msg.sender, 200000000*10**18);
    }
}
