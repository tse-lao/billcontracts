// TimeslotAds.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeslotAds is ERC1155, Ownable {
    using SafeMath for uint256;

    uint256 public constant TESTING_PHASE_DURATION = 7 days;
    uint256 public constant TIMESLOT_DURATION = 24 hours; // Changed from 1 hour to 24 hours
    uint256 public constant SLOTS_PER_MONTH = 30; // Changed from 30 * 24 (since we're now using days, not hours)
    
    uint256 public deploymentTime;
    
    mapping(uint256 => string) public adMetadataURI;
    mapping(uint256 => bool) public adVerifiedStatus;

    // Records the end time of the last created timeslot
    uint256 public lastTimeslotEndTime;

    mapping(uint256 => uint256) public adEndTime; // tokenId to end time

    constructor() ERC1155("") {
        deploymentTime = block.timestamp;
        // Set the lastTimeslotEndTime to the start of 20 August 2023
        lastTimeslotEndTime = 1679433600; // This is the UNIX timestamp for 20th August 2023, 00:00:00 UTC
    }

    function mintAdSpace(uint256 billboardId) external onlyOwner returns (uint256) {
        // Ensure we're past the testing phase
        require(block.timestamp > deploymentTime.add(TESTING_PHASE_DURATION), "Still in testing phase");

        // Ensure we're minting after the last timeslot
        require(block.timestamp > lastTimeslotEndTime, "Previous timeslots not yet finished");

        // Mint the timeslots for the month
        for(uint256 i = 0; i < SLOTS_PER_MONTH; i++) {
            uint256 startTime = lastTimeslotEndTime.add(i.mul(TIMESLOT_DURATION));
            uint256 tokenId = billboardId.mul(10**12).add(startTime); // Construct a unique token ID based on billboardId and startTime
            require(adEndTime[tokenId] == 0, "Timeslot already exists");

            _mint(msg.sender, tokenId, 1, ""); // Mint ERC1155 token
            adEndTime[tokenId] = startTime.add(TIMESLOT_DURATION);
        }

        // Update the end time of the last created timeslot
        lastTimeslotEndTime = lastTimeslotEndTime.add(SLOTS_PER_MONTH.mul(TIMESLOT_DURATION));

        return lastTimeslotEndTime;
    }
    
    function setAdMetadataURI(uint256 tokenId, string memory newURI) external onlyOwner() {
        adMetadataURI[tokenId] = newURI;
    }

    function verifyAd(uint256 tokenId) external {
        // This requires the Billboard contract to have a function that verifies the caller is the owner of a billboard
        adVerifiedStatus[tokenId] = true;
    }
}
