// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ICareerzenNFT {
    struct TokenInfo {
        address institution;
        string cid;
    }

    event TokenInfoAdded(uint256 indexed tokenId, string cid);

    /// @notice mint NFT
    function mint(uint256 tokenId, address to) external;
}