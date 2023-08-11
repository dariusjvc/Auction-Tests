const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Tests for NFTAuction", function () {
  let NFTAuction;
  let nftAuction;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  const minBid = ethers.utils.parseEther("0.001"); // Convert to Wei
  const auctionDuration = 5; // Auction duration in seconds 
  beforeEach(async function () {
    this.timeout(60000); 
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    NFTAuction = await ethers.getContractFactory("NFTAuction");
    nftAuction = await NFTAuction.deploy(
      "0x27cA174038Be8E186aEDbA8d5407A4891d81e068", // Real NFT Address
      minBid,
      auctionDuration
    );
    await nftAuction.deployed();
  });

  it("Deploy the contract", async function () {
    this.timeout(60000); 
    expect(await nftAuction.minBid()).to.equal(minBid);
  });

  it("Allow placing bids", async function () {
    this.timeout(60000); 

    // Convert the value to Wei using BigNumber
    const bidValue1 = ethers.utils.parseEther("0.001"); // Convert to Wei
    // address1 makes the first bid of 0.001 Ether
    await nftAuction.connect(addr1).placeBid(1, { value: bidValue1 }); 

    // Check that addr1 is the highest bidder for tokenId 1
    const auctionInfo1 = await nftAuction.auctions(1);
    expect(auctionInfo1.bidder).to.equal(addr1.address);
    expect(auctionInfo1.bidAmount).to.equal(bidValue1);

    // Convert the value to Wei using BigNumber
    const bidValue2 = ethers.utils.parseEther("0.002"); // Convert to Wei
    // address2 bids 0.002 Ether
    await nftAuction.connect(addr2).placeBid(1, { value: bidValue2 }); 

    // Verify that addr2 is the new highest bidder for tokenId 1
    const auctionInfo2 = await nftAuction.auctions(1);
    expect(auctionInfo2.bidder).to.equal(addr2.address);
    expect(auctionInfo2.bidAmount).to.equal(bidValue2);
  });

 it("Transfer NFT to highest bidder", async function () {
    const tokenId = 1; // ID of the token to auction
  
    const highestBidderAddress = "0x1f2DeACaeFf7541F9eE91Af0E8ea9202fEF14Df2"; // We assume that the second bidder is the winner
  
    // Increase the time by the auction duration to simulate the passage of time
    await ethers.provider.send("evm_increaseTime", [auctionDuration]);
    await ethers.provider.send("evm_mine");
  
    // Attempt to end the auction and transfer the NFT to the highest bidder
    await nftAuction.transferNFTToHighestBidder(tokenId);
  
    // Verify that the NFT has been transferred to the highest bidder
    const newOwner = await nftAuction.nftContract().ownerOf(tokenId);
    expect(newOwner).to.equal(highestBidderAddress);
  });

});
