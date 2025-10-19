# Guardian: A Smart Account Manager for Monad

**Guardian** is a decentralized application (dApp) built for the MetaMask Smart Accounts x Monad Dev Cook-Off. It provides a user-friendly security dashboard for managing the features of a smart account on the Monad network, focusing on the core principles of account abstraction.

## Features

This hackathon submission focuses on a core, fully-functional MVP:

* **Guardian Management:** Users can add and remove trusted "guardian" addresses. These guardians are the foundation for social recovery, allowing users to regain access to their accounts if they lose their primary key.
* **Spending Allowances:** Users can set a daily spending limit (in USD) to protect their account from unauthorized large transactions.
* **Live on Monad Testnet:** The smart contract is deployed and verified on the Monad Testnet, and the dApp is fully interactive.
    * **Contract Address:** `0xd3310739AF89EceC9EE327C17243C8347e252310`
    * **Verified Contract on Monad Explorer:** [https://explorer.testnet.monad.xyz/address/0xd3310739AF89EceC9EE327C17243C8347e252310](https://explorer.testnet.monad.xyz/address/0xd3310739AF89EceC9EE327C17243C8347e252310)

## Tech Stack

* **Smart Contract:** Solidity
* **Development Framework:** Foundry
* **Frontend:** HTML, TailwindCSS, vanilla JavaScript
* **Libraries:** Ethers.js
* **Blockchain:** Monad Testnet

## Getting Started Locally

1.  **Clone the repository.**
2.  **Run a local server:** Open the `index.html` file through a local server to enable wallet connections. A simple way is to run `python3 -m http.server` in the project directory.
3.  **Connect your wallet:** Open [http://localhost:8000](http://localhost:8000) in your browser and make sure your wallet is connected to the Monad Testnet.

---

This project demonstrates a practical and user-centric application of account abstraction, built with professional tools and best practices.