1ucoin

Welcome to 1ucoin (1ucoin.fun), a decentralized draw platform on Polygon! Join fun, low-cost draws for mainstream cryptocurrencies (BTC, ETH, BNB, SOL, etc., price > 1 USDT) with 1 USDT per share. Powered by Chainlink VRF for fair draws and QuickSwap for seamless swaps. Non-winners earn ODC tokens (1 USDT = 1 ODC).

Features

Low Entry: 1 USDT per share.

Dynamic Shares: Calculated via Chainlink Price Feeds for BTC, ETH, SOL, etc.

Fair Draws: Provably fair with Chainlink VRF.

DeFi Integration: USDT swapped via QuickSwap.

ODC Rewards: Non-winners get 1 ODC per USDT (100 ODC = 1 USDT).

Web3 UI: Modern, BetFury-inspired interface.

IP Protection: Secured via GitHub timestamps (Commit).

Files

1ucoin.sol: Core smart contract (View).

summary.txt: Draw mechanism summary (View).

algorithm.txt: Dynamic share allocation algorithm (View).

Installation

Clone the repo:

git clone https://github.com/luckyzmz/1ucoin.git
cd 1ucoin


Install dependencies:

npm install hardhat
npm install


Deploy smart contract on Polygon Mumbai:

npx hardhat run scripts/deploy.js --network mumbai

Update frontend (index.html) with contract address and deploy to Vercel:

vercel --prod

Usage

Visit 1ucoin.fun.

Connect MetaMask, select a coin (e.g., ETH, SOL).

Buy shares with 1 USDT each.

Await fair draw results and earn ODC if not winning.

Tokenomics

ODC Token: ERC-20 on Polygon.

Supply: 100M ODC.

Allocation: 50% user rewards, 20% liquidity, 15% team (locked 12 months), 10% marketing, 5% development.

IDO: Q3 2025 on QuickSwap (ODC/USDT, targeting 10,000 USDT).

Contributing

Contributions welcome! Fork, submit pull requests, or open issues.

License

MIT License

Donate: 

0x324FF0078dd9289aA639e3A2F87f634999999999 (ETH,BNB..)

