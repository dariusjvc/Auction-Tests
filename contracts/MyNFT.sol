// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// MyNFT contract inherits from ERC721URIStorage and Ownable
contract MyNFT is ERC721URIStorage, Ownable {
    constructor() ERC721("MyNFT", "MNFT") {}

    // Mint a new NFT with a specified token ID and token URI
    function mintNFT(address recipient, uint256 tokenId, string memory tokenURI) public onlyOwner {
        _mint(recipient, tokenId);         // Mint the NFT
        _setTokenURI(tokenId, tokenURI);   // Set the token URI for metadata
    }

    // Approve another address to transfer a specific NFT
    function approveNFTTransfer(uint256 tokenId, address approved) public onlyOwner {
        approve(approved, tokenId);        // Approve the specified address to transfer the NFT
    }
}
