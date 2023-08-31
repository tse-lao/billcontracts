// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BillboardV2.sol";  // Make sure this is the correct path to your BillboardAdSpace contract

contract BillboardFactory is Ownable {
    using SafeMath for uint256;

    // Array to store addresses of all created billboard contracts
    BillboardAdSpace[] public billboards;

    // Array to store addresses of billboards pending approval
    BillboardAdSpace[] public pendingBillboards;

    // Events
    event BillboardCreated(address indexed owner, address billboardAddress, uint256 timestamp, string name, string location, string size);
    event BillboardApproved(address indexed owner, address billboardAddress);
    event BillboardRemoved(address indexed owner, address billboardAddress);


    function createBillboardPendingApproval(
        string memory baseURI,
        string memory location,
        string memory size,
        string memory name, 
        uint256 timestamp 
    ) external {
        BillboardAdSpace billboard = new BillboardAdSpace(
            msg.sender,
            baseURI,
            location,
            size,
            name, 
            timestamp
        );
        pendingBillboards.push(billboard);
        emit BillboardCreated(msg.sender, address(billboard), timestamp, name, location, size);
    }

    function approveBillboard(uint256 index) external onlyOwner {
        require(index < pendingBillboards.length, "Invalid index");
        
        address approvedBillboardAddress = address(pendingBillboards[index]);
        
        billboards.push(pendingBillboards[index]);
        
        // Remove from the pending list using similar method as removeBillboard
        if (index != pendingBillboards.length - 1) {
            pendingBillboards[index] = pendingBillboards[pendingBillboards.length - 1];
        }
        pendingBillboards.pop();

        emit BillboardApproved(msg.sender, approvedBillboardAddress);
    }

    function removeBillboard(uint256 index) external onlyOwner {
        require(index < billboards.length, "Invalid index");

        address removedBillboardAddress = address(billboards[index]);

        // Move the last billboard to the slot to delete
        billboards[index] = billboards[billboards.length - 1];
        
        // Remove the last slot
        billboards.pop();

        emit BillboardRemoved(msg.sender, removedBillboardAddress);
    }

    function getTotalBillboards() external view returns (uint256) {
        return billboards.length;
    }

    function getTotalPendingBillboards() external view returns (uint256) {
        return pendingBillboards.length;
    }

    //Option to transfer it to a DAO to fulfill full decentralization on the contract
    function transferToDAO(address daoAddress) external onlyOwner {
        transferOwnership(daoAddress);
    }
}
