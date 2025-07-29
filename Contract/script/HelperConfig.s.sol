// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {ETH_SEPOLIA_CHAIN_ID, LOCAL_CHAIN_ID, BASE_FEE, GAS_PRICE, WEI_PER_UNIT_LINK} from "./Constants.sol";

import {VRFCoordinatorV2_5Mock} from "@chainlink.git/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "@chainlink.git/contracts/src/v0.8/functions/tests/v1_X/testhelpers/MockLinkToken.sol";

//Cấu hình mạng network
contract HelperConfig is Script {
    error InvalidNetworkConfig();

    struct NetworkConfig {
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;
        address account;
        address linkToken;
    }

    // Tùy thuộc vào mạng lưới, chúng ta sẽ có các cấu hình khác nhau
    NetworkConfig public localNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfigs;

    constructor(){
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaNetworkConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        }
        else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateLocalNetworkConfig();

        } else {
            revert InvalidNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 95236129135223493101957155465753121126622799164916155243895731604605150459253,
            account: 0x3C0174e25E866C3CE93DEb4883fAAf09e094CA72,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getOrCreateLocalNetworkConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(BASE_FEE, GAS_PRICE, WEI_PER_UNIT_LINK);
        uint256 subscriptionIdMock = vrfCoordinatorMock.createSubscription();
        MockLinkToken linkTokenMock = new MockLinkToken();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            vrfCoordinator: address(vrfCoordinatorMock),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: subscriptionIdMock,
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38,
            linkToken: address(linkTokenMock)
        });

        return localNetworkConfig;
    }
}