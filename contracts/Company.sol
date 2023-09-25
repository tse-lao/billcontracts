// SPDX-License-Identifier: MIT
// TBA Contract

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// 6551 Interfaces
interface IERC6551Registry {
    event AccountCreated(
        address account,
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    );

    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 seed,
        bytes calldata initData
    ) external returns (address);

    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view returns (address);
}

contract Company is Ownable, ERC721URIStorage, ERC2981 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct MultiSig {
        address[] signers;
        mapping(address => bool) hasSigned;
        uint8 signaturesRequired;
        uint8 signatureCount;
    }

    mapping(uint256 => MultiSig) private _multiSigs;
    
    //now we want to create a list of controllers of the nft and introduce 
    //TODO: 1. we want the multisig to be able to transfer a token from one account to another. 
    //TODO: we want to review all the data hold by an account 


    string public _baseTokenURI = "https://ipfs.io/ipfs/";

    IERC6551Registry public ERC6551Registry;
    address public ERC6551AccountImplementation;

    //create a list of admin that are able to combinely transfer tokens.

    // ----------------------------- CONSTRUCTOR ------------------------------

    constructor(
        address _ERC6551Registry,
        address _ERC6551AccountImplementation
    ) ERC721("CareerZen", "CZN") {
        //register 6551 for account implementation, for validating ownership and levels of DAO.
        ERC6551Registry = IERC6551Registry(_ERC6551Registry);
        ERC6551AccountImplementation = _ERC6551AccountImplementation;
    }

    ///////////////////////////////////////////////
    //         MINTING PROCESS    == KYC         //
    ///////////////////////////////////////////////


    // Minting process is done in 2 steps:
    // 1. User calls registration of a DAO membership, with proof of KYC
    // 2. we check if users is KYC registered and generate a ERC6551 account for the user.
    function mint() external payable {
        //require that the user hold a certain NFT to be able to mint, but also make it posisble that they can only mint once.
        //TODO: 2. register the user address that has a soulbond token with the DAO
        uint256 newItemId = _tokenIds.current();
        _tokenIds.increment();
        //TODO: 3. change this to a single mint function for the DAO registry.
        _mint(msg.sender, 1);

        // Check that the TBA creation was success
        require(tokenBoundCreation(newItemId), "TBA creation failed");
    }

    function tokenBoundCreation(uint256 tokenId) internal returns (bool) {
        ERC6551Registry.createAccount(
            ERC6551AccountImplementation,
            block.chainid,
            address(this),
            tokenId + 1,
            0,
            abi.encodeWithSignature("initialize()", msg.sender)
        );

        return true;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer Failed");
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        emit BatchMetadataUpdate(1, type(uint256).max);
        _baseTokenURI = baseURI;
    }



    // Interfaces support
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC2981, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    ////////////////////////////////////////
    //              GETTERS               //
    ////////////////////////////////////////

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function getTBA(uint256 _tokenId) external view returns (address) {
        return
            ERC6551Registry.account(
                ERC6551AccountImplementation,
                block.chainid,
                address(this),
                _tokenId,
                0
            );
    }


    ////////////////////////////////////////
    //              HELPERS               //
    ////////////////////////////////////////

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721) {
        require(from == address(0), "Token not transferable");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
    
    function setMultiSig(uint256 tokenId, address[] memory signers, uint8 signaturesRequired) external onlyOwner {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        //TODO: FIX THIS ISSUE. Y
        _multiSigs[tokenId] = MultiSig({
            signers: signers,
            signaturesRequired: signaturesRequired,
            signatureCount: 0
        });

        for (uint i = 0; i < signers.length; i++) {
            _multiSigs[tokenId].hasSigned[signers[i]] = false;
        }
    }

    function sign(uint256 tokenId) external {
        require(_multiSigs[tokenId].hasSigned[msg.sender] == false, "Already signed");
        
        for (uint i = 0; i < _multiSigs[tokenId].signers.length; i++) {
            if (_multiSigs[tokenId].signers[i] == msg.sender) {
                _multiSigs[tokenId].hasSigned[msg.sender] = true;
                _multiSigs[tokenId].signatureCount++;
                break;
            }
        }
    }

    function isSigned(uint256 tokenId) external view returns (bool) {
        return _multiSigs[tokenId].signatureCount >= _multiSigs[tokenId].signaturesRequired;
    }
}
