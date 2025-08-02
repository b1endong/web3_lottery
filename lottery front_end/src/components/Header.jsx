import {AppKitAccountButton, useAppKit} from "@reown/appkit/react";
import {useAppKitAccount, useWalletInfo} from "@reown/appkit/react";

function shortenAddress(address, chars = 4) {
    if (!address || address.length < chars * 2 + 2) return address;
    return `${address.slice(0, chars + 2)}...${address.slice(-chars)}`;
}

export default function Header() {
    const {open} = useAppKit();
    const {walletInfo} = useWalletInfo();

    const {address, isConnected} = useAppKitAccount();

    return (
        <header className="flex-center-between py-4 border-b-2">
            <div className="flex-center">
                <h1 className="text-2xl font-bold">Lottery</h1>
                {isConnected && (
                    <div className="flex ml-3 relative hover:bg-gray-200 p-2 transition-all rounded-lg">
                        <a
                            href={`https://sepolia.etherscan.io/address/${address}`}
                        >
                            {shortenAddress(address)}
                        </a>
                        <i className="fa-solid fa-arrow-up-right-from-square"></i>
                    </div>
                )}
            </div>
            <button
                className="bg-gray-500 hover:bg-black text-white font-bold py-2 px-4 rounded-xl transition-all"
                onClick={() => open()}
            >
                {isConnected ? shortenAddress(address) : "Connect Wallet"}
            </button>
        </header>
    );
}
