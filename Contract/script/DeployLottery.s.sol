// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {ENTRANCE_FEE, CALLBACK_GAS_LIMIT} from "./Constants.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployLottery is Script {
    HelperConfig helper = new HelperConfig();
    HelperConfig.NetworkConfig config = helper.getConfig();

    function run () external {
        deployLottery();
    }

    // constructor(uint256 entranceFee, 
    //             address vrfCoordinator, 
    //             bytes32 keyHash, 
    //             uint32 callbackGasLimit, 
    //             uint256 subscriptionId) {
    //     i_EntranceFee = entranceFee;
    //     s_lotteryState = LotteryState.OPEN;
    //     i_subscriptionId = subscriptionId;
    //     i_vrfCoordinator = vrfCoordinator;
    //     i_keyHash = keyHash;
    //     i_callbackGasLimit = callbackGasLimit;

    function deployLottery() public returns (Lottery) {
        vm.startBroadcast(config.account);
        Lottery lottery = new Lottery(ENTRANCE_FEE, config.vrfCoordinator, config.keyHash, CALLBACK_GAS_LIMIT, config.subscriptionId);
        vm.stopBroadcast();
        return lottery;
    }
}