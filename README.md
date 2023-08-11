# Auction-Tests
Auction-Tests

# Requirements
node v16.0.0

# Previously deployed 
Owner --> 0xa9902ea9e293381F67B1611C9425C109E25D252E 
NFT Address --> 0x27cA174038Be8E186aEDbA8d5407A4891d81e068 (using MyNFT.sol)
Bidder1 --> 0x5a345cE5d0adae69bB2B36dc87dDe32E2F5AE873
Bidder2 --> 0x1f2DeACaeFf7541F9eE91Af0E8ea9202fEF14Df2


# How to install
git clone https://github.com/dariusjvc/Auction-Tests.git
npm install
npx hardhat compile

# Run the tests with:
npx hardhat test

# How to run 
There are three tests, the first makes the deployment, the second bids from two users and the third sends the nft to the highest bidder. We assume that the second bidder is the winner, and in the third test the send is made to that winner.



