// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@opengsn/contracts/src/ERC2771Recipient.sol";

contract UserProfile is ERC2771Recipient {

    struct UserInfo {
        string username;
        string additionalInfo;
        string profileHash;  // IPFS hash, or any other hash to the user's profile
    }

    mapping(address => UserInfo) public userProfiles;
    mapping(address => uint256) public lastUpdateTimestamp; // Mapping to store the last update timestamp for each user.

    uint256 public constant UPDATE_INTERVAL = 30 days;  // Define a constant for the 30-day interval
    
    constructor(address _forwarder) {
        _setTrustedForwarder(_forwarder);
    }
    

    event UserProfileUpdated(address indexed user, string username, string additionalInfo, string profileHash);

    modifier canUpdate(address user) {
        require(
            lastUpdateTimestamp[user] + UPDATE_INTERVAL <= block.timestamp,
            "Can only update once every month via relayer."
        );
        _;
    }

    /**
     * @dev Register or update a user's profile using a relayer.
     * @param _username The user's chosen username.
     * @param _additionalInfo Any additional information the user wants to store.
     * @param _profileHash Hash pointing to the user's detailed profile (e.g., an IPFS hash).
     */
    function registerOrUpdateProfileViaRelayer(string memory _username, string memory _additionalInfo, string memory _profileHash) external canUpdate(_msgSender()) {
        UserInfo memory newUserProfile = UserInfo({
            username: _username,
            additionalInfo: _additionalInfo,
            profileHash: _profileHash
        });

        userProfiles[_msgSender()] = newUserProfile;
        lastUpdateTimestamp[_msgSender()] = block.timestamp; // Update the last update timestamp for the user.

        emit UserProfileUpdated(_msgSender(), _username, _additionalInfo, _profileHash);
    }

    /**
     * @dev Direct function to register or update a user's profile.
     * @param _username The user's chosen username.
     * @param _additionalInfo Any additional information the user wants to store.
     * @param _profileHash Hash pointing to the user's detailed profile (e.g., an IPFS hash).
     */
    function registerOrUpdateProfile(string memory _username, string memory _additionalInfo, string memory _profileHash) external {
        UserInfo memory newUserProfile = UserInfo({
            username: _username,
            additionalInfo: _additionalInfo,
            profileHash: _profileHash
        });

        userProfiles[msg.sender] = newUserProfile;
        lastUpdateTimestamp[msg.sender] = block.timestamp; // Update the last update timestamp for the user.

        emit UserProfileUpdated(msg.sender, _username, _additionalInfo, _profileHash);
    }

    /**
     * @dev Retrieve a user's profile using their address.
     * @param user The address of the user.
     * @return The user's profile information.
     */
    function getProfile(address user) external view returns (UserInfo memory) {
        return userProfiles[user];
    }
}
