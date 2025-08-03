import Time from "./Time.jsx";
import EnterLottery from "./EnterLottery.jsx";
import LotteryInfo from "./LotteryInfo.jsx";
import {useAppKitProvider, useAppKitAccount} from "@reown/appkit/react";
import {contractAddress, contractAbi} from "../contract/ContractData.jsx";
import {
    BrowserProvider,
    Contract,
    formatEther,
    formatUnits,
    parseEther,
} from "ethers";
import {useEffect, useState} from "react";
import {
    enterLottery,
    getLotteryState,
    getPlayersLen,
    getRecentRewardBalance,
    getEntranceFee,
    getLastTimeStamp,
    getInterval,
} from "../contract/ContractInteraction.jsx";

export default function Body() {
    const {walletProvider} = useAppKitProvider("eip155");
    const [lotteryState, setLotteryState] = useState(0);
    const [entranceFee, setEntranceFee] = useState(0);
    const [playersLen, setPlayersLen] = useState(0);
    const [recentReward, setRecentReward] = useState(0);
    const [totalRewardBalance, setTotalRewardBalance] = useState(0);
    const [lastTimeStamp, setLastTimeStamp] = useState(0);
    const [interval, setInterval] = useState(0);
    const [isLoading, setIsLoading] = useState(false);

    const fetchContractData = async () => {
        if (!walletProvider) return;

        setIsLoading(true);
        try {
            const ethersProvider = new BrowserProvider(walletProvider);
            const contractBalance = await ethersProvider.getBalance(
                contractAddress
            );
            const lotteryState = await getLotteryState(ethersProvider);
            const entranceFee = await getEntranceFee(ethersProvider);
            const playersLen = await getPlayersLen(ethersProvider);
            const recentReward = await getRecentRewardBalance(ethersProvider);
            const lastTimeStamp = await getLastTimeStamp(ethersProvider);
            const interval = await getInterval(ethersProvider);

            setTotalRewardBalance(formatEther(contractBalance));
            setLotteryState(lotteryState);
            setEntranceFee(formatEther(entranceFee));
            setPlayersLen(playersLen);
            setRecentReward(formatEther(recentReward));
            setLastTimeStamp(Number(lastTimeStamp));
            setInterval(Number(interval));

            console.log("Total Reward Balance:", formatEther(contractBalance));
            console.log("Lottery State:", lotteryState);
            console.log("Entrance Fee:", formatEther(entranceFee));
            console.log("Players Length:", playersLen);
            console.log("Recent Reward:", formatEther(recentReward));
            console.log("Last Time Stamp:", Number(lastTimeStamp));
            console.log("Interval:", Number(interval));
        } catch (error) {
            console.error("Error fetching contract data:", error);
        } finally {
            setIsLoading(false);
        }
    };

    const handleEnterLottery = async () => {
        if (!walletProvider) return;
        const ethersProvider = new BrowserProvider(walletProvider);
        const signer = await ethersProvider.getSigner();
        try {
            const tx = await enterLottery(signer, parseEther(entranceFee));
            console.log("Entered Lottery Successfully", tx);
            fetchContractData();
        } catch (error) {
            console.error("Error entering lottery:", error);
        }
    };

    useEffect(() => {
        fetchContractData();
    }, [walletProvider]);

    useEffect(() => {
        if (!walletProvider) return;

        const intervalId = setInterval(() => {
            fetchContractData();
        }, 5000); // gọi lại mỗi 5 giây

        return () => clearInterval(intervalId);
    }, [walletProvider]);

    return (
        <>
            <div className="flex justify-center mb-4"></div>
            <h1 className="text-2xl font-bold">
                Total Prize Pool: {totalRewardBalance} ETH
            </h1>
            <div className="grid gap-3 grid-cols-3 grid-rows-3 my-7">
                <Time
                    _lastTimeStamp={lastTimeStamp}
                    _interval={interval}
                    _state={lotteryState}
                />
                <LotteryInfo
                    _recentReward={recentReward}
                    _playersLen={playersLen}
                />
                <EnterLottery
                    _lotteryState={lotteryState}
                    _entranceFee={entranceFee}
                    _enterLottery={handleEnterLottery}
                />
            </div>
        </>
    );
}
