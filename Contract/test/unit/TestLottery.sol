// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ENTRANCE_FEE, LOCAL_CHAIN_ID} from "../../script/Constants.sol";
import {Lottery} from "../../src/Lottery.sol";
import {Test} from "forge-std/Test.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink.git/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "@chainlink.git/contracts/src/v0.8/functions/tests/v1_X/testhelpers/MockLinkToken.sol";

contract TestLottery is Test {
    Lottery private lottery;
    address private PLAYER = makeAddr("player");
    uint256 private constant PLAYER_STARTING_BALANCE = 10 ether;
    HelperConfig helper = new HelperConfig();
    HelperConfig.NetworkConfig config;
    
    event LotteryEntered(address player);

    function setUp() public {
        DeployLottery deployer = new DeployLottery();
        (lottery, helper) = deployer.deployLottery();
        vm.deal(PLAYER, PLAYER_STARTING_BALANCE);
        config = helper.getConfig();

        //Set up Chainlink VRF
        if (block.chainid == LOCAL_CHAIN_ID){
            vm.startPrank(config.account);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).addConsumer(config.subscriptionId, address(lottery));
            MockLinkToken(config.linkToken).setBalance(config.account, 100 ether);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).fundSubscription(
                config.subscriptionId,
                100 ether
            );  
            vm.stopPrank();
        }
    }

    function test_SetUp() public view {
        assertEq(lottery.getEntranceFee(), ENTRANCE_FEE);
        assertEq(lottery.getVrfCoordinator(), config.vrfCoordinator);
    }

    function test_LotteryEnter() public {
        //Test error
        vm.expectRevert();
        lottery.enterLottery();

        //Action 
        vm.expectEmit();
        emit LotteryEntered(PLAYER);
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        //Assertions
        assertEq (PLAYER.balance, PLAYER_STARTING_BALANCE - ENTRANCE_FEE);
        assertEq (lottery.getRewardBalance(), ENTRANCE_FEE);
        assertEq (lottery.getPlayersLength(), 1);
        assertEq (lottery.getPlayerByIndex(0), PLAYER);
    }

    function test_lotteryRequestId() public {
        //Test error
        lottery.lotteryRequestId();
    }
}
//         //Action
//         vm.prank(PLAYER);
//         lottery.enterLottery{value: ENTRANCE_FEE}();
//
//         //Assertions
//         assertEq (PLAYER.balance, PLAYER_STARTING_BALANCE - ENTRANCE_FEE);
//         assertEq (lottery.getRewardBalance(), ENTRANCE_FEE);
// }
