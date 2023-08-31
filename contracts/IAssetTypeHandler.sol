// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IAssetTypeHandler {
    function validateAssetData(string calldata data) external view returns (bool);
    // Additional functions specific to the asset type can be added here
}
