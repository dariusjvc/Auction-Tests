const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('NFTAuction tests:', function () {
  let nftAuction;
  let myNFT;
  let owner, bidder1, bidder2;
  let minBid;
  let duration;
  let tokenId;

  before(async () => {
    const MyNFT = await ethers.getContractFactory('MyNFT');
    myNFT = await MyNFT.deploy();
    await myNFT.deployed();

    const NFTAuction = await ethers.getContractFactory('NFTAuction');
    minBid = ethers.utils.parseEther('0.1');
    duration = 60; // 1 minute

    nftAuction = await NFTAuction.deploy(myNFT.address, minBid, duration);
    await nftAuction.deployed();

    [owner, bidder1, bidder2] = await ethers.getSigners();

    // Mint NFT for the auction
    tokenId = 1;
    await myNFT.connect(owner).mintNFT(owner.address, tokenId, 'tokenURI');

    // Approve NFT transfer to the auction contract
    await myNFT.connect(owner).approve(nftAuction.address, tokenId);

    // Start auction
    await nftAuction.connect(owner).startAuction(tokenId);
  });

  it('This test verifies that the MyNFT smart contract has been deployed', async function () {
    expect(myNFT.address).to.not.equal(0);
  });

  it('This test verifies that the NFTAuction smart contract has been deployed', async function () {
    expect(nftAuction.address).to.not.equal(0);
  });

  it('This test verifies the correct initial values for NFTAuction', async function () {
    expect(await nftAuction.owner()).to.equal(owner.address);
    expect(await nftAuction.nftContract()).to.equal(myNFT.address);
    expect(await nftAuction.minBid()).to.equal(ethers.utils.parseEther('0.1'));
    expect(await nftAuction.auctionEndTime()).to.be.above(0);
    expect(await nftAuction.auctionState()).to.equal(0); 
  });

  it('This test allow bidder1 to place a bid', async function () {
    await nftAuction.connect(bidder1).placeBid(tokenId, { value: minBid });
    const auction = await nftAuction.auctions(tokenId);
    expect(auction.bidder).to.equal(bidder1.address);
    expect(auction.bidAmount).to.equal(minBid);
  });

  it('This test allow bidder2 to place a higher bid', async function () {
    const higherBid = minBid.add(ethers.utils.parseEther('0.2'));
    await nftAuction.connect(bidder2).placeBid(tokenId, { value: higherBid });
    const auction = await nftAuction.auctions(tokenId);
    expect(auction.bidder).to.equal(bidder2.address);
    expect(auction.bidAmount).to.equal(higherBid);
  });

  it('This test should transfer NFT to the highest bidder after auction ends', async function () {
    // Place bids
    await nftAuction.connect(bidder1).placeBid(tokenId, { value: minBid.add(ethers.utils.parseEther('0.3')) });
    await nftAuction.connect(bidder2).placeBid(tokenId, { value: minBid.add(ethers.utils.parseEther('0.4')) });

    // Advance time to auction end
    await ethers.provider.send('evm_increaseTime', [duration]);
    await ethers.provider.send('evm_mine');

    // End auction
    await nftAuction.connect(owner).endAuction(tokenId);

    // Verify NFT transfer to the highest bidder
    const ownerAfter = await myNFT.ownerOf(tokenId);
    expect(ownerAfter).to.equal(bidder2.address);
  });
});
