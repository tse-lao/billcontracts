// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";


contract BillboardInteraction is ERC2771Recipient {

    IERC20 public rewardToken; 
    mapping(address => mapping(uint256 => address)) public depositors;  // billboard => tokenId => depositor
    mapping(address => mapping(uint256 => uint256)) public balances;  // billboard => tokenId => balance
    mapping(address => mapping(uint256 => uint256)) public rewardAmounts;  // billboard => tokenId => rewardAmount
    mapping(address => mapping(uint256 => mapping(address => bool))) public hasInteracted;

    event UserInteraction(
        address indexed user,
        address indexed billboardAddress,
        uint256 indexed tokenId,
        uint256 timestamp,
        string profile
    );

    constructor(address _rewardToken, address _forwarder) {
        rewardToken = IERC20(_rewardToken);
        _setTrustedForwarder(_forwarder);

    }

    //TODO: we change the register of interaction with  the submitted hash, tokenid and owner of the contract at that point.
    function registerInteraction(address billboardAddress, uint256 tokenId, string memory _profile) external {
        require(!hasInteracted[billboardAddress][tokenId][_msgSender()], "User has already interacted with this billboard and token ID");

        uint256 reward = rewardAmounts[billboardAddress][tokenId];
        require(balances[billboardAddress][tokenId] >= reward, "Insufficient funds for reward");

        balances[billboardAddress][tokenId] -= reward;  // Deduct reward from balance
        hasInteracted[billboardAddress][tokenId][_msgSender()] = true;

        require(rewardToken.transfer(_msgSender(), reward), "Failed to transfer rewards");
        emit UserInteraction(_msgSender(), billboardAddress, tokenId, block.timestamp, _profile);
    }

    function depositTokens(address billboardAddress, uint256 tokenId, uint256 amount) external {
        require(depositors[billboardAddress][tokenId] == address(0) || depositors[billboardAddress][tokenId] == msg.sender, "Another user has already deposited for this billboard and token ID");

        depositors[billboardAddress][tokenId] = _msgSender();
        balances[billboardAddress][tokenId] += amount;  
        require(rewardToken.transferFrom(_msgSender(), address(this), amount), "Failed to transfer tokens for deposit");
    }

    function setRewardAmount(address billboardAddress, uint256 tokenId, uint256 reward) external {
        require(depositors[billboardAddress][tokenId] == _msgSender(), "Not the depositor for this billboard and token ID");
        rewardAmounts[billboardAddress][tokenId] = reward;
    }

    function withdrawRemainingBalance(address billboardAddress, uint256 tokenId) external {
        require(depositors[billboardAddress][tokenId] == _msgSender(), "Not the depositor for this billboard and token ID");

        uint256 remainingBalance = balances[billboardAddress][tokenId];
        balances[billboardAddress][tokenId] = 0;  
        require(rewardToken.transfer(_msgSender(), remainingBalance), "Failed to transfer remaining balance");
        depositors[billboardAddress][tokenId] = address(0);
    }

    function getContractBalanceForToken(address billboardAddress, uint256 tokenId) external view returns (uint256) {
        return balances[billboardAddress][tokenId];
    }
}
