// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTAuction is Ownable, IERC721Receiver {
    using Counters for Counters.Counter;

    struct Auction {
        uint256 tokenId;
        address bidder;
        uint256 bidAmount;
    }

    IERC721 public nftContract;
    uint256 public minBid;
    uint256 public auctionEndTime;

    Counters.Counter private auctionIdCounter;
    mapping(uint256 => Auction) public auctions;

    enum AuctionState { Active, Ended }
    AuctionState public auctionState;

    modifier onlyBeforeEnd() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        _;
    }

    constructor(address _nftContract, uint256 _minBid, uint256 _duration) {
        nftContract = IERC721(_nftContract);
        minBid = _minBid;
        auctionEndTime = block.timestamp + _duration;
        auctionState = AuctionState.Active;
    }

    function startAuction() external onlyOwner onlyBeforeEnd {
        auctionState = AuctionState.Active;
    }

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

    function endAuction(uint256 _tokenId) external onlyOwner onlyAfterEnd {
        require(auctionState == AuctionState.Active, "Auction is not active");

        Auction storage auction = auctions[_tokenId];
        require(auction.bidder != address(0), "No bids received");

        auctionState = AuctionState.Ended;
        nftContract.safeTransferFrom(address(this), auction.bidder, _tokenId);
    }

    function withdraw(uint256 _tokenId) external onlyOwner {
        require(auctionState == AuctionState.Ended, "Auction has not ended yet");

        Auction storage auction = auctions[_tokenId];
        require(auction.bidder == address(0), "Auction already ended");

        auctionState = AuctionState.Active;

        payable(owner()).transfer(auction.bidAmount);
        delete auctions[_tokenId];
    }

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

    function transferNFTToHighestBidder(uint256 _tokenId) external onlyOwner onlyAfterEnd {
    require(auctionState == AuctionState.Ended, "Auction has not ended yet");

    Auction storage auction = auctions[_tokenId];
    require(auction.bidder != address(0), "No bids received");

    address highestBidder = auction.bidder;

    auctionState = AuctionState.Active;

    nftContract.safeTransferFrom(address(this), highestBidder, _tokenId);
    delete auctions[_tokenId];
}
}
