import {useAppKitProvider, useAppKitAccount} from "@reown/appkit/react";
import {BrowserProvider, Contract, formatUnits} from "ethers";
import {contractAddress, contractAbi} from "./ContractData.jsx";

const {address, isConnected} = useAppKitAccount();
const {walletProvider} = useAppKitProvider("eip155");

//Read
export const getTotalRewardBalance = async (ethersProvider, contract) => {
    try {
        const balance = await ethersProvider.getBalance(contract);
        return formatEther(balance);
    } catch (error) {
        return null;
    }
};

export const getPlayersLen = async (ethersProvider) => {
    try {
        const contract = new Contract(
            contractAddress,
            contractAbi,
            ethersProvider
        );
        const playersLen = await contract.getPlayersLength();
        return Number(playersLen.length);
    } catch (error) {
        return null;
    }
};

export const getLotteryState = async (ethersProvider) => {
    try {
        const contract = new Contract(
            contractAddress,
            contractAbi,
            ethersProvider
        );
        const state = await contract.getLotteryState();
        return state.toString();
    } catch (error) {
        return null;
    }
};

export const getRecentRewardBalance = async (ethersProvider) => {
    try {
        const contract = new Contract(
            contractAddress,
            contractAbi,
            ethersProvider
        );
        const recentReward = await contract.getRewardBalance();
        return formatEther(recentReward);
    } catch (error) {
        return null;
    }
};
