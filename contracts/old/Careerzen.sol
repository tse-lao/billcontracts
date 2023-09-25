// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ICareerzen} from "../interfaces/ICareerzen.sol";
import {ICareerzenNFT} from "../interfaces/ICareerzenNFT.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Careerzen is Ownable2Step, ICareerzen {
    mapping(address institution => bool whitelisted) public whitelist;
    mapping(address institution => mapping(address user => bool confirmed)) public confirms;
    mapping(address user => mapping(string category => uint256 tokenId)) public defaultImages;

    bytes32 public immutable DOMAIN_SEPARATOR;

    // keccak256("Permit(address to,uint256 tokenId")
    bytes32 private constant PERMIT_TYPEHASH = 0xa639ea6048f9421a9d6132574feac8419b5cba16a75a3a236a349d4ee52a6bdb;
    ICareerzenNFT public careerzenNFT;

    struct Permit {
        address to;
        uint256 tokenId;
    }

    modifier onlyWhitelisted() {
        if (!whitelist[msg.sender]) {
            revert Careerzen__NotWhitelisted();
        }
        _;
    }

    constructor(address _careerzenNFT) {
        careerzenNFT = ICareerzenNFT(_careerzenNFT);
        DOMAIN_SEPARATOR = keccak256(abi.encode(block.chainid));
    }

    // TODO: Implement mint function
    function mint(uint256 tokenId) public {
        // mint NFT from CareerzenNFT
        careerzenNFT.mint(tokenId, msg.sender);
    }

    /// @notice Institution confirms the user address
    function confirm(address to) public onlyWhitelisted {
        confirms[msg.sender][to] = true;

        emit Confirmed(msg.sender, to);
    }

    /// @notice Admin whitelists an institution so it can confirm users
    function addToWhitelist(address institution) public onlyOwner {
        whitelist[institution] = true;

        emit Whitelisted(institution);
    }

    // function setDefaultImage(string memory category, uint256 tokenId) external {
    //     if (careerzenNFT.balanceOf(msg.sender, tokenId) == 0) {
    //         revert Careerzen__NotOwner();
    //     }

    //     return defaultImages[msg.sender][category] = tokenId;
    // }

    // function getDefaultImage(address user, string memory category) external returns (uint256) {
    //     return defaultImages[user][category];
    // }
}
