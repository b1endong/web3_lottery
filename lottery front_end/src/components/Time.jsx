import {useState, useEffect, useRef} from "react";

export default function Time({_lastTimeStamp, _interval, _state}) {
    const [timeLeft, setTimeLeft] = useState(180); // 180 giây mặc định
    const [isWaitingForWinner, setIsWaitingForWinner] = useState(false);
    const timerRef = useRef(null);

    // Tính toán thời gian ban đầu từ contract data
    useEffect(() => {
        console.log(isWaitingForWinner);
        if (_lastTimeStamp && _interval && _state != 1) {
            const currentTime = Math.floor(Date.now() / 1000);
            const timeSinceLastUpdate = currentTime - _lastTimeStamp;
            const remainingTime = _interval - timeSinceLastUpdate;

            console.log("Current Time:", currentTime);
            console.log("Time Since Last Update:", timeSinceLastUpdate);
            console.log("Remaining Time:", remainingTime);

            if (remainingTime > 0) {
                setTimeLeft(remainingTime);
            } else {
                setTimeLeft(180); // Reset về 180s nếu đã hết thời gian
            }
        }
    }, [_lastTimeStamp, _interval, _state]);

    // Timer đếm ngược
    useEffect(() => {
        // Clear timer cũ nếu có
        if (timerRef.current) {
            clearInterval(timerRef.current);
        }

        timerRef.current = setInterval(() => {
            // Kiểm tra trạng thái lottery
            if (_state == 1) {
                setIsWaitingForWinner(true);
                return;
            }

            setIsWaitingForWinner(false);

            // Đếm ngược
            setTimeLeft((prev) => {
                if (prev <= 1) {
                    // Khi hết thời gian, kiểm tra có người chơi không
                    // Nếu không có người chơi, reset về 180s
                    console.log("Timer finished, resetting to 180s");
                    return 180;
                }
                return prev - 1;
            });
        }, 1000);

        // Cleanup function
        return () => {
            if (timerRef.current) {
                clearInterval(timerRef.current);
            }
        };
    }, [_state]); // Chỉ dependency _state để tránh restart timer không cần thiết

    // Debug: Console log để kiểm tra props
    useEffect(() => {
        console.log("Time Component Props:", {
            _lastTimeStamp,
            _interval,
            _state,
            timeLeft,
            isWaitingForWinner,
        });
    }, [_lastTimeStamp, _interval, _state, timeLeft]);

    // Format thời gian hiển thị
    const formatTime = (seconds) => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins.toString().padStart(2, "0")}:${secs
            .toString()
            .padStart(2, "0")}`;
    };

    // Lấy màu sắc dựa trên thời gian còn lại
    const getTimeColor = () => {
        if (isWaitingForWinner) return "text-yellow-500";
        if (timeLeft <= 30) return "text-red-500";
        if (timeLeft <= 60) return "text-orange-500";
        return "text-green-500";
    };

    return (
        <div className="col-span-3 row-start-1 border-box">
            <h1 className="text-2xl font-bold">Time Remaining</h1>
            {isWaitingForWinner ? (
                <div className="flex flex-col items-center">
                    <p className="text-yellow-500 text-xl font-bold animate-pulse">
                        Picking Winner...
                    </p>
                    <p className="text-sm text-gray-600 mt-1">
                        Please wait while the system selects a winner
                    </p>
                </div>
            ) : (
                <div className="flex flex-col items-center">
                    <p className={`text-4xl font-bold ${getTimeColor()}`}>
                        {formatTime(timeLeft)}
                    </p>
                    <p className="text-sm text-gray-600 mt-1">
                        {timeLeft <= 30 ? "Hurry up!" : "Time until next draw"}
                    </p>
                </div>
            )}
        </div>
    );
}
