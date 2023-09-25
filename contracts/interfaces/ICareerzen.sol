// SPDX-License-Identifier
pragma solidity 0.8.19;

interface ICareerzen {
    event Confirmed(address indexed institution, address indexed user);

    event Whitelisted(address indexed institution);

    error Careerzen__InvalidSigner();
    error Careerzen__NotWhitelisted();
    error Careerzen__NotOwner();

    // function DOMAIN_SEPERATOR() external view returns (bytes32);

    function confirms(address institution, address user) external view returns (bool);

    function confirm(address to) external;

    function addToWhitelist(address institution) external;

    function mint(uint256 tokenId) external;
}