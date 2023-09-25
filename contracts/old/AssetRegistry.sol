// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IAssetTypeHandler.sol";

contract AssetRegistry is ERC721Enumerable, ERC721URIStorage, Ownable {
    struct AssetType {
        string name;
        string description;
        address handlerContract; // Address of the associated contract
    }

    struct Asset {
        uint256 typeId;
        address nft;
        uint256 tokenId;
        string metadataURI;
    }

    mapping(address => bool) public approvedContracts;

    mapping(uint256 => AssetType) public assetTypes;
    mapping(uint256 => Asset) public assets;

    uint256 public assetTypeCount = 0;
    uint256 public assetCount = 0;

    event AssetTypeAdded(
        uint256 typeId,
        string name,
        string description
    );

    event AssetRegistered(
        uint256 assetId,
        uint256 typeId,
        uint256 tokenId,
        string metadataURI
    );
    
    event ApprovedAddress(address indexed contractAddress, bool isApproved);

    constructor() ERC721("AssetRegistry", "ASR") {}

    function addAssetType(
        string memory name,
        string memory description
    ) external onlyOwner returns (uint256 typeId) {
        assetTypeCount++;
        assetTypes[assetTypeCount] = AssetType(name, description, msg.sender);

        emit AssetTypeAdded(assetTypeCount, name, description);

        return assetTypeCount;
    }



    function setApprovedContract(
        address contractAddress,
        bool isApproved
    ) external onlyOwner {
        approvedContracts[contractAddress] = isApproved;
        emit ApprovedAddress(contractAddress, isApproved);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721URIStorage, ERC721) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721Enumerable, ERC721) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorage, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function registerAssetByContract(
        uint256 typeId,
        uint256 tokenId,
        string memory metadataURI, 
        address owner
    ) external returns (uint256) {
        require(
            approvedContracts[msg.sender],
            "Contract not approved to register assets"
        );
        require(typeId <= assetTypeCount, "Invalid asset type");


        assetCount++;
        assets[assetCount] = Asset(typeId, msg.sender, tokenId, metadataURI);

        _safeMint(owner, assetCount);
        _setTokenURI(assetCount, metadataURI);

        emit AssetRegistered(assetCount, typeId, tokenId, metadataURI);

        return assetCount;
    }

    function getAssetDetails(
        uint256 assetId
    ) external view returns (Asset memory) {
        require(assetId <= assetCount, "Invalid asset ID");
        return assets[assetId];
    }
}
