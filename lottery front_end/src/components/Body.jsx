import Time from "./Time.jsx";
import EnterLottery from "./EnterLottery.jsx";
import LotteryInfo from "./LotteryInfo.jsx";

export default function Body() {
    return (
        <div className="grid gap-3 grid-cols-3 grid-rows-3 my-7">
            <Time />
            <LotteryInfo />
            <EnterLottery />
        </div>
    );
}
