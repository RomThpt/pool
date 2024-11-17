// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract Pool is Ownable {
    address private immutable i_owner;

    constructor(address _owner) Ownable(_owner) {
        i_owner = _owner;
    }
}
