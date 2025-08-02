import {createAppKit} from "@reown/appkit/react";
import {EthersAdapter} from "@reown/appkit-adapter-ethers";
import {sepolia} from "@reown/appkit/networks";
import Header from "./components/Header.jsx";
import Body from "./components/Body.jsx";

const projectId = "5674d7b480388430c52265ecd231d75d";

const networks = [sepolia];

const metadata = {
    name: "Web3 Lottery",
    description: "Lottery DApp built with Web3 technologies",
    url: "https://mywebsite.com",
    icons: ["https://avatars.mywebsite.com/"],
};

createAppKit({
    adapters: [new EthersAdapter()],
    networks,
    metadata,
    projectId,
    features: {
        analytics: true,
    },
});

function App() {
    return (
        <div className="mx-auto container">
            <Header />
            <Body />
        </div>
    );
}

export default App;
