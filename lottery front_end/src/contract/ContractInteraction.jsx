import {useAppKitProvider, useAppKitAccount} from "@reown/appkit/react";
import {BrowserProvider, Contract, formatUnits, formatEther} from "ethers";
import {contractAddress, contractAbi} from "./ContractData.jsx";

//Read
export const getTotalRewardBalance = async (ethersProvider, contract) => {
    try {
        const balance = await ethersProvider.getBalance(contract);
        return formatEther(balance);
    } catch (error) {
        return null;
    }
};

export const getEntranceFee = async (ethersProvider) => {
    try {
        const contract = new Contract(
            contractAddress,
            contractAbi,
            ethersProvider
        );
        const entranceFee = await contract.getEntranceFee();
        return entranceFee;
    } catch (error) {
        console.error("Error fetching entrance fee:", error);
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
        return Number(playersLen);
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
        const state = await contract.getLotteryState({blockTag: "latest"});
        console.log("Lottery State:", state);
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
        return recentReward;
    } catch (error) {
        return null;
    }
};

export const getLastTimeStamp = async (ethersProvider) => {
    try {
        const contract = new Contract(
            contractAddress,
            contractAbi,
            ethersProvider
        );
        const lastTimeStamp = await contract.getLastTimeStamp();
        return lastTimeStamp;
    } catch (error) {
        return null;
    }
};

export const getInterval = async (ethersProvider) => {
    try {
        const contract = new Contract(
            contractAddress,
            contractAbi,
            ethersProvider
        );
        const interval = await contract.i_interval();
        return interval;
    } catch (error) {
        return null;
    }
};

//Write
export const enterLottery = async (signer, amount) => {
    try {
        const contract = new Contract(contractAddress, contractAbi, signer);
        const tx = await contract.enterLottery({value: amount});
        await tx.wait();
        return tx;
    } catch (error) {
        console.error("Error entering lottery:", error);
        return false;
    }
};

export const winnerWithdraw = async (signer) => {
    try {
        const contract = new Contract(contractAddress, contractAbi, signer);
        const tx = await contract.winnerWithdraw();
        await tx.wait();
        return tx;
    } catch (error) {
        console.error("Error withdrawing winner:", error);
        return false;
    }
};
