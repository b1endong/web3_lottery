// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VRFConsumerBaseV2Plus} from "@chainlink.git/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink.git/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
contract Lottery is VRFConsumerBaseV2Plus {
   
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
    
    //Chainlink VRF variables
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS =  1;


    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event LotteryEntered(address player);
    event LotteryRequestId(uint256 requestId);
    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(uint256 entranceFee, 
                address vrfCoordinator, 
                bytes32 keyHash, 
                uint32 callbackGasLimit, 
                uint256 subscriptionId) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_EntranceFee = entranceFee;
        s_lotteryState = LotteryState.OPEN;
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
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

    function lotteryRequestId() public returns (uint256 requestId) {

       requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        emit LotteryRequestId(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
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

    function getVrfCoordinator() external view returns (address) {
        return address(s_vrfCoordinator);
    }
}
