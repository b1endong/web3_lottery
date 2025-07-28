// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions


contract Lottery {
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    error Lottery_InvalidEntranceFee();
    error Lottery_NotOpen();

    /*//////////////////////////////////////////////////////////////
                            TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    enum LotteryState {
        OPEN,
        CLOSED
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 private immutable i_EntranceFee;
    uint256 private s_rewardBalance;
    address[] private s_players;
    LotteryState private s_lotteryState;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event LotteryEntered(address player);

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(uint256 ENTRANCE_FEE) {
        i_EntranceFee = ENTRANCE_FEE;
        s_lotteryState = LotteryState.OPEN;
    }

    /*//////////////////////////////////////////////////////////////
                            ACTION FUNCTION
    //////////////////////////////////////////////////////////////*/
    function enterLottery() external payable {
        if (s_lotteryState != LotteryState.OPEN) {
            revert Lottery_NotOpen();
        }


        if (msg.value != i_EntranceFee) {
            revert Lottery_InvalidEntranceFee();
        }
        
        s_rewardBalance += msg.value;
        s_players.push(msg.sender);
        
        emit LotteryEntered(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                            GETTER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function getEntranceFee() external view returns (uint256) {
        return i_EntranceFee;
    }

    function getRewardBalance() external view returns (uint256) {
        return s_rewardBalance;
    }

    function getPlayersLength() external view returns (uint256) {
        return s_players.length;
    }

    function getPlayerByIndex(uint256 index) external view returns (address){
        return s_players[index];
    }
}
