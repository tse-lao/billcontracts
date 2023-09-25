// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ICareerzen} from "../interfaces/ICareerzen.sol";
import {ICareerzenNFT} from "../interfaces/ICareerzenNFT.sol";

// TODO: Only CareerzenRegistry is allowed to mint
contract CareerzenNFT is ERC1155, ICareerzenNFT, Ownable2Step {
    ICareerzen public careerZen;

    mapping(uint256 tokenId => TokenInfo tokenInfo) public tokenIdInfo;

    // TODO: add uri
    constructor() ERC1155("ipfs://") {}
    

    function setMinter(address _careerZen) external onlyOwner {
        careerZen = ICareerzen(_careerZen);
    }

    /// @notice This function can be called only from Careerzen
    function mint(uint256 tokenId, address to) external onlyAllowed {
        require(balanceOf(to, tokenId) == 0, "CareerzenNFT: token already minted");

        if (msg.sender != owner()) {
            address institution = getInstitution(tokenId);
            require(institution != address(0), "CareerzenNFT: TokenInfo not added");
            // User must have been confirmed by the institution
            require(careerZen.confirms(institution, to), "CareerzenNFT: user not confirmed");
        }

        _mint(to, tokenId, 1, "");
    }

    modifier onlyAllowed() {
        require(
            msg.sender == address(careerZen) || msg.sender == owner(), "CareerzenNFT: only Owner or Careerzen can call"
        );
        _;
    }

    /* ==================== Admin functions ==================== */

    function addTokenInfo(uint256 tokenId, address institution, string memory cid) external onlyOwner {
        require(tokenIdInfo[tokenId].institution == address(0), "CareerzenNFT: token info already exists");
        TokenInfo memory tokenInfo = TokenInfo(institution, cid);
        tokenIdInfo[tokenId] = tokenInfo;

        emit TokenInfoAdded(tokenId, cid);
    }
    

    /* ==================== Getter functions ==================== */

    function getInstitution(uint256 tokenId) public view returns (address) {
        return tokenIdInfo[tokenId].institution;
    }

    function getCid(uint256 tokenId) public view returns (string memory) {
        return tokenIdInfo[tokenId].cid;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
