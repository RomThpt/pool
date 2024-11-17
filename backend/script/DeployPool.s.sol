// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Pool} from "../src/Pool.sol";

contract DeployPool is Script {
    Pool public pool;

    function run() public {
        
        vm.startBroadcast();
        pool = new Pool(1 weeks, 10 ether);
        vm.stopBroadcast();
    }
}
