// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ENTRANCE_FEE} from "../../script/Constants.sol";
import {Lottery} from "../../src/Lottery.sol";
import {Test} from "forge-std/Test.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";

contract TestLottery is Test {
    Lottery private lottery;
    address private PLAYER = makeAddr("player");
    uint256 private constant PLAYER_STARTING_BALANCE = 10 ether;
    event LotteryEntered(address player);

    function setUp() public {
        DeployLottery deployer = new DeployLottery();
        lottery = deployer.deployLottery();
        vm.deal(PLAYER, PLAYER_STARTING_BALANCE);
    }

    function testSetUp() public view {
        assertEq(lottery.getEntranceFee(), ENTRANCE_FEE);
    }

    function testLotteryEnter() public {
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
}
