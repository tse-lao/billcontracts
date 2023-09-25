pragma solidity ^0.8.4;
//this will be the tokenbound account registry including the multiple categories for it 
import "@openzeppelin/contracts/access/Ownable.sol";



//1. check if the account has a valid kyc. 
//2. create a account inlcuding in mapping to the other accounts.. 
//3. add the functionalities to the registery for whitelisting accounts. 
//4. make it possible to return and update the accounts history. 

//TODO: add in the ERC6551
contract CareerZenAccount is Ownable {

    address public careerNFT;
    
    struct Category {
        string name;
        address categoryAddress;
    }
    
    mapping(address => Category) public categories;
    //we want all the category to be added manually. 
    
    constructor(){}
    
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 seed,
        bytes calldata initData
    ) public view returns (address){ 
        return implementation;
    };
    
    
}