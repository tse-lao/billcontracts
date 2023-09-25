// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BillboardAdSpace is ERC721Enumerable, ReentrancyGuard {
    using SafeMath for uint256;
    string private baseURI;
    struct AdSpace {
        address owner;
        string adContent;
        string pendingContent;
        uint256 price;
    }

    struct Auction {
        uint256 startPrice;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        bool active;
    }

    struct BillboardDetails {
        string location;
        string size;
        string name;
        string baseURI;
        address owner;
    }

    struct Rental {
        uint256 endTime;
        string renterContent;
    }

    mapping(uint256 => AdSpace) public adSpaces;
    mapping(uint256 => Auction) public adSpaceAuctions;
    mapping(uint256 => Rental) public adSpaceRentals;

    uint256 public defaultRentalDuration = 86400;
    address public collectionOwner;
    uint256 public startTime;
    uint256 public newestTime;
    BillboardDetails public billboardDetails;

    event AuctionStarted(uint256 adId, uint256 startPrice, uint256 endTime);
    event NewBid(uint256 adId, address bidder, uint256 bidAmount);
    event AuctionEnded(uint256 adId, address winner);
    event Rented(uint256 adId, address renter, uint256 endTime);
    event Mint(uint256 adId, address owner, uint256 price);
    event BatchMint(uint256 startTime, uint256 endTime, uint256 amount, address owner);

    constructor(
        address owner,
        string memory _baseURI,
        string memory _location,
        string memory _size,
        string memory _name, 
        uint256 _timestamp
    ) ERC721(_name, "BAS") {
        startTime = _timestamp;
        newestTime = _timestamp;
        collectionOwner = owner;

        baseURI = _baseURI;
        billboardDetails = BillboardDetails({
            location: _location,
            size: _size,
            name: _name, 
            baseURI: _baseURI,
            owner: owner
        });
        
        //batch mint for a year
    }
    
    function batchMint(uint amount) external {
        uint256 oldTime = newestTime;
        for (uint256 i = 0; i < amount; i++) {
            
            uint256 newTokenId = oldTime + ((i+1) * defaultRentalDuration);
            _safeMint(collectionOwner, newTokenId);
            adSpaces[newTokenId] = AdSpace({
                owner: collectionOwner,
                adContent: "",
                pendingContent: "",
                price: 0
            });
        }
        newestTime = newestTime + (amount * defaultRentalDuration);
        totalSupply().add(amount);
        
        emit BatchMint(oldTime, newestTime, amount, msg.sender);
    }

    function createAdSpace(uint timestamp, uint256 price) external {
        uint256 newAdId = totalSupply().add(1); // New token ID
        require(msg.sender == collectionOwner, "Only the collection owner can create new ad spaces");
        
        //the id can be represnting the timestamp so. 
        // we want to calculate the start time of the ad space. and then make sure that it is not in the past.
        
        //we also want to make sure that the timestamp is divisible by the default rental duration.
        require((timestamp - startTime) % defaultRentalDuration == 0, "Timestamp must be divisible by the default rental duration");
        //we also want to make sure that the timestamp does not already exist as a token Id 
        require(!_exists(timestamp), "Token with this timestamp already exists");
        _mint(msg.sender, timestamp);
        adSpaces[newAdId] = AdSpace({
            owner: msg.sender,
            adContent: "",
            pendingContent: "",
            price: price
        });
        
        //need to emit an evenet here 
        emit Mint(newAdId, msg.sender, price);
        
    }

    // Setting ad content now sets the pending content
    function setPendingAdContent(
        uint256 adId,
        string calldata content
    ) external {
        require(
            ownerOf(adId) == msg.sender || msg.sender == adSpaces[adId].owner,
            "Not the owner of this ad space"
        );
        adSpaces[adId].pendingContent = content;
    }

    // Approve the pending content
    function approveAdContent(uint256 adId) external {
        require(msg.sender == collectionOwner, "Only the collection owner can approve the content");

        adSpaces[adId].adContent = adSpaces[adId].pendingContent;
        adSpaces[adId].pendingContent = ""; // Clear the pending content
    }

    // Reject the pending content (simply clear it without setting the main content)
    function rejectAdContent(uint256 adId) external {
        require(
            ownerOf(adId) == msg.sender,
            "Only the owner can reject content"
        );
        adSpaces[adId].pendingContent = ""; // Clear the pending content
    }

    function buyAdSpace(uint256 adId) external payable nonReentrant {
        require(msg.value == adSpaces[adId].price, "Incorrect Ether sent");

        // Transfer ownership
        address previousOwner = ownerOf(adId);
        _transfer(previousOwner, msg.sender, adId);
        adSpaces[adId].owner = msg.sender;

        // Send the funds to the previous owner
        payable(previousOwner).transfer(msg.value);
    }

    // Auction related functions
    function startAuction(
        uint256 adId,
        uint256 startPrice,
        uint256 duration
    ) external {
        require(ownerOf(adId) == msg.sender, "Not the owner");
        require(!adSpaceAuctions[adId].active, "Auction already active");

        adSpaceAuctions[adId] = Auction({
            startPrice: startPrice,
            endTime: block.timestamp.add(duration),
            highestBidder: address(0),
            highestBid: 0,
            active: true
        });

        emit AuctionStarted(adId, startPrice, block.timestamp.add(duration));
    }

    function placeBid(uint256 adId) external payable nonReentrant {
        require(adSpaceAuctions[adId].active, "No active auction");
        require(
            block.timestamp < adSpaceAuctions[adId].endTime,
            "Auction has ended"
        );
        require(msg.value > adSpaceAuctions[adId].highestBid, "Bid is too low");

        // Refund the previous highest bidder
        if (adSpaceAuctions[adId].highestBidder != address(0)) {
            payable(adSpaceAuctions[adId].highestBidder).transfer(
                adSpaceAuctions[adId].highestBid
            );
        }

        adSpaceAuctions[adId].highestBidder = msg.sender;
        adSpaceAuctions[adId].highestBid = msg.value;

        emit NewBid(adId, msg.sender, msg.value);
    }

    function endAuction(uint256 adId) external {
        require(adSpaceAuctions[adId].active, "No active auction");
        require(
            block.timestamp >= adSpaceAuctions[adId].endTime,
            "Auction has not ended yet"
        );

        adSpaceAuctions[adId].active = false;

        // Transfer ownership of the ad space to the highest bidder
        address previousOwner = ownerOf(adId);
        _transfer(previousOwner, adSpaceAuctions[adId].highestBidder, adId);

        // Transfer the funds to the previous owner
        payable(previousOwner).transfer(adSpaceAuctions[adId].highestBid);

        emit AuctionEnded(adId, adSpaceAuctions[adId].highestBidder);
    }

    // Rental related functions
    function rentAdSpaceWithSpecificDuration(
        uint256 adId,
        string calldata content,
        uint256 duration
    ) public payable {
        require(
            block.timestamp > adSpaceRentals[adId].endTime,
            "Ad space is currently rented"
        );
        require(
            msg.value == adSpaces[adId].price,
            "Incorrect Ether sent for rental"
        );

        adSpaceRentals[adId] = Rental({
            endTime: block.timestamp.add(duration),
            renterContent: content
        });

        // Transfer the funds to the owner of the ad space
        payable(ownerOf(adId)).transfer(msg.value);

        emit Rented(adId, msg.sender, block.timestamp.add(duration));
    }

    function getAdContent(uint256 adId) public view returns (string memory) {
        if (block.timestamp <= adSpaceRentals[adId].endTime) {
            return adSpaceRentals[adId].renterContent;
        }
        return adSpaces[adId].adContent;
    }

    function rentAdSpace(
        uint256 adId,
        string calldata content
    ) external payable {
        rentAdSpaceWithSpecificDuration(adId, content, defaultRentalDuration);
    }

    // Override the tokenURI function
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        // Create a dynamic portion of the URI using timestamp and ad content
        string memory dynamicURI = string(
            abi.encodePacked(
                "/",
                adSpaces[tokenId].adContent
            )
        );

        return string(abi.encodePacked(baseURI, dynamicURI));
    }

    // Helper function to convert uint256 to string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
