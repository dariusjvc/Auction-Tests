# Auction-Tests
Auction-Tests

# Requirements
node v16.0.0

# Smart Contracts
1. MyNFT.sol
2. NFTAuction.sol

# How to install
git clone https://github.com/dariusjvc/Auction-Tests.git
npm install
npx hardhat compile

# Run the tests with:
npx hardhat test

# Description 
There the following tests:

1. Test1: Verifies that the MyNFT smart contract has been deployed
2. Test2: Verifies that the NFTAuction smart contract has been deployed
3. Test3: Verifies the correct initial values for NFTAuction
4. Test4: Allow bidder1 to place a bid
5. Test5: Allow bidder2 to place a higher bid
6. Test6: Transfer NFT to the highest bidder after auction ends




