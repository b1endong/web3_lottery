import {useState, useEffect} from "react";

export default function Time({_lastTimeStamp, _interval, _state}) {
    const [timeLeft, setTimeLeft] = useState(0);
    const [isActive, setIsActive] = useState(false);

    useEffect(() => {
        if (_lastTimeStamp && _interval) {
            const nextDrawTime = _lastTimeStamp + _interval;
            const now = Math.floor(Date.now() / 1000);
            const remaining = nextDrawTime - now;

            console.log(
                "Next Draw Time:",
                new Date(nextDrawTime * 1000).toLocaleString()
            );
            console.log("Current Time:", new Date(now * 1000).toLocaleString());
            console.log("Remaining Time (seconds):", remaining);

            if (remaining > 0) {
                setTimeLeft(remaining);
                setIsActive(true);
            } else {
                setTimeLeft(0);
                setIsActive(false);
            }
        }
    }, [_lastTimeStamp, _interval]);

    useEffect(() => {
        let intervalId = null;

        if (isActive && timeLeft > 0) {
            intervalId = setInterval(() => {
                setTimeLeft((time) => {
                    if (time <= 1) {
                        setIsActive(false);
                        return 0;
                    }
                    return time - 1;
                });
            }, 1000);
        }
        return () => {
            if (intervalId) clearInterval(intervalId);
        };
    }, [isActive, timeLeft]);

    const formatTime = (seconds) => {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;

        return `${hours.toString().padStart(2, "0")}:${minutes
            .toString()
            .padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
    };

    return (
        <div className="col-span-3 border-box py-5">
            <div className="flex-center flex-col">
                <h3 className="text-lg font-semibold mb-4">Next Draw In</h3>
                <div className="text-3xl font-bold text-blue-600 mb-2">
                    {timeLeft > 0 ? formatTime(timeLeft) : "00:00:00"}
                </div>
                <div className="text-sm text-gray-500">
                    {timeLeft > 0 ? "Time Remaining" : "Drawing Soon..."}
                </div>
                {_interval > 0 && (
                    <div className="text-xs text-gray-400 mt-2">
                        Draw Interval: {Math.floor(_interval / 60)} minutes
                    </div>
                )}
            </div>
        </div>
    );
}
