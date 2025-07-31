// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ENTRANCE_FEE, LOCAL_CHAIN_ID, AUTO_INTERVAL} from "../../script/Constants.sol";
import {Lottery} from "../../src/Lottery.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
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
    event LotteryWinner(address winner, uint256 amount);
    event LotteryRequestId(uint256 indexed requestId);
    event WinnerWithdraw(address player, uint256 amount);

    modifier hasPlayerAndTimePassed(){
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();
        vm.roll(block.number + 1);
        vm.warp(block.timestamp + AUTO_INTERVAL + 1);
        _;
    }

    modifier skipForkTest() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
            _;
    }

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

    function test_lotteryRequestId() skipForkTest public {
        //Test revert when no players
        vm.expectRevert(Lottery.Lottery_NotEnoughPlayers.selector);
        // lottery.lotteryRequestId();

        //Add player and request lottery
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();
        // uint256 requestId = lottery.lotteryRequestId();

        //Test revert when trying to enter after lottery is closed
        vm.expectRevert(Lottery.Lottery_NotOpen.selector);
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        //Expect emit event
        vm.expectEmit();
        emit LotteryWinner(PLAYER, ENTRANCE_FEE);
        //Action - fulfill random words
        // VRFCoordinatorV2_5Mock(config.vrfCoordinator).fulfillRandomWords(
        //     requestId, 
        //     address(lottery)
        // );

        //Assertions
        assertEq(lottery.getWinner(), PLAYER);
        assertEq(lottery.getCurrentWinnerBalance(PLAYER), ENTRANCE_FEE);
        assert(Lottery.LotteryState.OPEN == lottery.getLotteryState());
        assertEq(lottery.getPlayersLength(), 0);
        assertEq(lottery.getRewardBalance(), 0);
    }

    function test_checkUpkeep() skipForkTest() public {
        //False upkeepNeeded 
        (bool upkeepNeeded1,) = lottery.checkUpkeep("");
        assertFalse(upkeepNeeded1);

        //Add player and check upkeep
        vm.prank(PLAYER);
        lottery.enterLottery{value: ENTRANCE_FEE}();
        //False when lottery's time stamp is not enough
        (bool upkeepNeeded2 ,) = lottery.checkUpkeep("");
        assertFalse(upkeepNeeded2);

        //Time passed 
        vm.roll (block.number + 1 );
        vm.warp(block.timestamp + AUTO_INTERVAL + 1);
        //True when time passed and players exist
        (bool upkeepNeeded3,) = lottery.checkUpkeep("");
        assert(upkeepNeeded3);

        lottery.performUpkeep("");
        (bool upkeepNeeded4,) = lottery.checkUpkeep("");
        assertFalse(upkeepNeeded4);
    }

    function test_performUpkeep() skipForkTest() hasPlayerAndTimePassed() public {
        //Expect emit event requestId
        vm.expectEmit();
        emit LotteryRequestId(1);

        vm.recordLogs();
        lottery.performUpkeep("");

        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.log("Event requestId: ", uint256(entries[1].topics[1]));
        uint256 requestIdLog = uint256(entries[1].topics[1]);

        VRFCoordinatorV2_5Mock(config.vrfCoordinator).fulfillRandomWords(
            requestIdLog, 
            address(lottery)
        );

        //Assertions
        assertEq(lottery.getWinner(), PLAYER);
        assertEq(lottery.getCurrentWinnerBalance(PLAYER), ENTRANCE_FEE);
        assert(Lottery.LotteryState.OPEN == lottery.getLotteryState());
        assertEq(lottery.getLastTimeStamp(), block.timestamp);
    }

    function test_winnerWithdraw() hasPlayerAndTimePassed() skipForkTest public {

        //Expect revert when winner balance is not enough
        vm.expectRevert(Lottery.Lottery_WinnerBalanceNotEnough.selector);
        vm.prank(PLAYER);
        lottery.winnerWithdraw();

        //Winner picked
        vm.recordLogs();
        lottery.performUpkeep("");

        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.log("Event requestId: ", uint256(entries[1].topics[1]));
        uint256 requestIdLog = uint256(entries[1].topics[1]);

        VRFCoordinatorV2_5Mock(config.vrfCoordinator).fulfillRandomWords(
            requestIdLog, 
            address(lottery)
        );

        //Expect emit event winner withdraw
        assertEq(lottery.getCurrentWinnerBalance(PLAYER), ENTRANCE_FEE);
        
        vm.expectEmit();
        emit WinnerWithdraw(PLAYER, ENTRANCE_FEE);

        vm.prank(PLAYER);
        lottery.winnerWithdraw();

        assertEq(lottery.getCurrentWinnerBalance(PLAYER), 0);
    }
}
