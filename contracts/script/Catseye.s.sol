// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Catseye} from "../src/Catseye.sol";

contract CounterScript is Script {
    Catseye public catseye;
    address oracle = address(0xa5C42A3af93561Ee349CdA19D9c828855598F410);

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        catseye = new Catseye(oracle);

        vm.stopBroadcast();
    }
}
