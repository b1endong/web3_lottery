export default function EnterLottery({
    _lotteryState,
    _entranceFee,
    _enterLottery,
}) {
    return (
        <div className="col-span-2 row-span-2 border-box">
            <div className="flex-center gap-2">
                <h2 className="text-xl font-bold mb-4">Lottery State: </h2>
                {_lotteryState == 0 ? (
                    <p className="text-green-500 text-xl font-bold mb-4 ">
                        Open
                    </p>
                ) : (
                    <p className="text-red-500 text-xl font-bold mb-4">
                        Closed
                    </p>
                )}
            </div>
            <div className="flex-center gap-2 mb-4">
                <p className="">
                    ENTRANCE FEE: <strong>{_entranceFee}</strong>
                </p>
                <button
                    className="bg-gray-500 font-bold hover:bg-black transition-all text-white p-2 rounded "
                    onClick={_enterLottery}
                >
                    Enter Lottery
                </button>
            </div>
            <p className="text-gray-600">Stay tuned for updates and results.</p>
        </div>
    );
}
