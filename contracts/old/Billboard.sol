// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//import "./AssetRegistry.sol";
import "./TimeSlotAds.sol";


//make this a ERC2116 forward contract to make sure th
contract Billboard is ERC721URIStorage, Ownable {
    //AssetRegistry public assetRegistry;
    uint256 public billboardAssetTypeId; // The type ID for billboards in the AssetRegistry
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds;
    TimeslotAds public timeslotAds;
    
    event BillboardRegistered(address creator, uint256 tokenId, string metadataURI, uint256 longitude, uint256 latitude);

    constructor(
       // address _assetRegistryAddress,
       // uint256 _billboardAssetTypeId, 
        address _timeslotAdsAddress

    ) ERC721("Billboard", "BLBD") {
        // assetRegistry = AssetRegistry(_assetRegistryAddress);
        // billboardAssetTypeId = _billboardAssetTypeId;
         timeslotAds = TimeslotAds(_timeslotAdsAddress);

    }
    

    function registerBillboard(
        uint256 longitude,
        uint256 latitude,
        string memory metadataURI
    ) external  returns (uint256) {
        //require(address(assetRegistry) != address(0), "AssetRegistry address not set");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, metadataURI);

        // Register the billboard as an asset in the AssetRegistry
        /* assetRegistry.registerAssetByContract(
            billboardAssetTypeId,
            newItemId,
            metadataURI, 
            msg.sender
        );
         */
        emit BillboardRegistered(msg.sender, newItemId, metadataURI, longitude, latitude);

        return newItemId;
    }
    
    //create the timeslots for each billboard
    
        
    
    //create a dao that is able to confirm or reject that there is indeed a billboard on the palce. 
    

}
