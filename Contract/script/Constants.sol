// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

uint256 constant ENTRANCE_FEE = 0.01 ether;
uint32 constant CALLBACK_GAS_LIMIT = 100000;

//Chain id 
uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
uint256 constant LOCAL_CHAIN_ID = 31337;

//Constant for VRF MOCKs
uint96 constant BASE_FEE = 0.25 ether;
uint96 constant GAS_PRICE = 1e9; // 1 gwei
int256 constant WEI_PER_UNIT_LINK = 1e18; // 1 LINK = 1e18 wei

//Chainlink Automation constants
uint256 constant AUTO_INTERVAL = 180;