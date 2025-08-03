export default function LotteryInfo({_recentReward, _playersLen}) {
    return (
        <>
            <div className="col-span-1 border-box">
                <h1 className="text-2xl font-bold">Reward Balance</h1>
                <p>
                    {_recentReward} <strong>ETH</strong>
                </p>
            </div>
            <div className="col-span-1 row-start-3 border-box">
                <h1 className="text-2xl font-bold">Total Players</h1>
                <p>
                    {_playersLen} <strong>PLAYERS</strong>
                </p>
            </div>
        </>
    );
}
