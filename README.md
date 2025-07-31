# 🎲 Web3 Lottery using Chainlink VRF

A simple decentralized lottery application built with Solidity and Chainlink Oracles to generate verifiable random numbers on-chain.

---

## 📌 Overview

This project demonstrates how to create a fair and trustless lottery system using:

-   **Solidity** smart contracts
-   **Chainlink VRF (Oracle)** for randomness
-   **Chainlink Automation (Oracle)** for automated on picking winner
-   **Hardhat / Foundry** for development and testing
-   **Ethers.js / Web3.js** for frontend interaction (optional)

---

## 🎯 Features

-   Players can enter the lottery by sending a fixed amount of ETH.
-   A winner is selected randomly using Chainlink VRF.
-   Prize is transferred automatically to the winner.
-   All logic is executed on-chain and verifiable.

---

## 🧱 Technologies Used

-   Solidity (`^0.8.x`)
-   Chainlink VRF v2
-   Chainlink Automation
-   Hardhat / Foundry (development & testing)
-   Chainlink Oracle Network
-   Ethers.js (optional frontend integration)

---

## ⚙️ How It Works

1. Users call `enterLottery()` and pay the entrance fee.
2. Once the lottery ends, the contract requests a random number from Chainlink VRF.
3. The random number is used to pick a winner from the list of participants.
4. The winner receives the ETH balance from the contract.

---
