# 🎮 Ethereum Tic Tac Toe DApp

This is a simple **Tic Tac Toe game powered by Ethereum smart contracts**. Two players can deposit ETH, play against each other, and the winner automatically receives the total reward.

## ✨ Features
- ✅ **Decentralized**: Runs entirely on the Ethereum blockchain.
- 🎯 **Game Mechanics**:
  - Two players each deposit **0.001 ETH** to start.
  - Players take turns marking the 3×3 board.
  - Winner receives the **0.002 ETH prize**.
  - If the game ends in a draw, players can withdraw their deposits.
- 🖥️ **Frontend**:
  - Built in plain HTML + JavaScript (no frameworks required).
  - Connects to MetaMask for transactions.
  - Displays the game board and updates state in real time.

## 🧩 Smart Contract
Written in Solidity, the contract:
- Validates moves and checks for winners.
- Stores board state on-chain.
- Manages ETH deposits and payouts securely.
- Allows players to withdraw if a game never starts.

## 🚀 How to Use
1. **Deploy the contract** to Ethereum (or a testnet like Goerli).
2. **Update the frontend JavaScript** with your contract address and ABI.
3. Serve `index.html` on GitHub Pages or any static hosting.
4. Connect MetaMask and start playing!

## 🛡️ Security Notes
- Only the two joined players can play.
- Funds are locked until game completion or withdrawal.
- Always test on testnets before deploying on mainnet.

---

### 🧑‍💻 Author
Created for educational purposes to demonstrate Ethereum smart contract development and Web3 integration.

Feel free to modify the code, improve the UI, or extend the game logic!
