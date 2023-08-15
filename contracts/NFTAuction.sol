// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTAuction is Ownable, IERC721Receiver {
    using Counters for Counters.Counter;

    // Structure to store auction details
    struct Auction {
        uint256 tokenId;    // ID of the token being auctioned
        address bidder;     // Address of the current bidder
        uint256 bidAmount;  // Current bid amount
    }

    // ERC721 contract used for the auction
    IERC721 public nftContract;

    // Minimum bid amount and auction end time
    uint256 public minBid;
    uint256 public auctionEndTime;

    // Auction ID counter and mapping for auction details
    Counters.Counter private auctionIdCounter;
    mapping(uint256 => Auction) public auctions;

    // Mapping to track NFT owners
    mapping(uint256 => address) public nftOwners;

    // Possible auction states
    enum AuctionState { Active, Ended }
    AuctionState public auctionState;

    // Modifier to allow only before auction end
    modifier onlyBeforeEnd() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    // Modifier to allow only after auction end
    modifier onlyAfterEnd() {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        _;
    }

    // Contract constructor
    constructor(address _nftContract, uint256 _minBid, uint256 _duration) {
        nftContract = IERC721(_nftContract);
        minBid = _minBid;
        auctionEndTime = block.timestamp + _duration;
        auctionState = AuctionState.Active;
    }

    // Function to start an auction
    function startAuction(uint256 _tokenId) external onlyOwner onlyBeforeEnd {
        require(nftContract.ownerOf(_tokenId) == owner(), "Only the NFT owner can start the auction");
        nftOwners[_tokenId] = owner(); // Set the current owner as the NFT owner
        auctionState = AuctionState.Active;
    }

    // Function to place a bid in the auction
    function placeBid(uint256 _tokenId) external payable onlyBeforeEnd {
        require(auctionState == AuctionState.Active, "Auction is not active");
        require(msg.value >= minBid, "Bid amount is below minimum");

        Auction storage auction = auctions[_tokenId];
        require(msg.value > auction.bidAmount, "Bid amount is too low");

        if (auction.bidder != address(0)) {
            // Refund the previous bidder
            payable(auction.bidder).transfer(auction.bidAmount);
        }

        auction.bidder = msg.sender;
        auction.bidAmount = msg.value;
        auction.tokenId = _tokenId;
    }

    // Function to end an auction
    function endAuction(uint256 _tokenId) external onlyOwner onlyAfterEnd {
        require(auctionState == AuctionState.Active, "Auction is not active");

        Auction storage auction = auctions[_tokenId];
        require(auction.bidder != address(0), "No bids received");

        auctionState = AuctionState.Ended;

        // Transfer the NFT to the highest bidder
        nftContract.transferFrom(nftOwners[_tokenId], auction.bidder, _tokenId);
        nftOwners[_tokenId] = address(0); // Set as ownerless NFT

        // Rest of the code for refunds and auction data cleanup
    }

    // Function to receive NFTs and check if the auction is active
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override returns (bytes4) {
        require(auctionState == AuctionState.Active, "Auction is not active");
        require(msg.sender == address(nftContract), "Only accepting NFTs");
        require(data.length == 0, "Data not supported");
        return this.onERC721Received.selector;
    }
}
