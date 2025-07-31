// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {ENTRANCE_FEE, CALLBACK_GAS_LIMIT, AUTO_INTERVAL} from "./Constants.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployLottery is Script {
    HelperConfig helper = new HelperConfig();
    HelperConfig.NetworkConfig config = helper.getConfig();

    function run () external {
        deployLottery();
    }

    function deployLottery() public returns (Lottery, HelperConfig) {
        vm.startBroadcast(config.account);
        Lottery lottery = new Lottery(ENTRANCE_FEE, config.vrfCoordinator, config.keyHash, CALLBACK_GAS_LIMIT, config.subscriptionId, AUTO_INTERVAL);
        vm.stopBroadcast();
        return (lottery, helper);
    }

    
}