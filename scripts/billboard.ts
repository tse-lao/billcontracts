// scripts/deploy_asset_registry.js

import { toBigInt } from "ethers";

const hre = require("hardhat");



export async function deployBillboard() {
    const Billboard = await hre.ethers.getContractFactory("Billboard");
    const deployAssets = "0xF1745fc0B254A69000FEcA62F02B2Fe740a0C614"
    const deployedTime = "0xd89329A3DF1a8da9B4ec8F31C29D7589cf046C9a"
    const billBoard = await Billboard.deploy({ gasLimit: 10000000});
    await billBoard.waitForDeployment();
    const billBoardAddress = await billBoard.getAddress();
    console.log(`Asset Registry deployed to: ${billBoardAddress}`)
    return billBoardAddress;
  }
  
  async function whitelistAssetType(assetRegistry: any, billboardAddress: any) {
    const assetFactory = await hre.ethers.getContractFactory("AssetRegistry");
    const assetInteractor = await assetFactory.attach(assetRegistry);
  
    const tx = await assetInteractor.setApprovedContract(billboardAddress, true);
    console.log(tx);
    console.log("Asset type whitelisted")
  }
  

export async function registerBillBoard(address:any, lat: any, long: any) {
    const addressFactory = await hre.ethers.getContractFactory(
        "Billboard"
    );
    
    
    
    const deployedContract =
    await addressFactory.attach(
        address
    );
  const metadataURI = "ipfs://samplemetadata"; // Placeholder URI for testing
  
  await deployedContract.registerBillboard(toBigInt(lat), toBigInt(long), metadataURI, { gasLimit: 1000000 }); // Using type ID and location ID 0 (the ones we just added)
  console.log(`Asset registered with Metadata URI: ${metadataURI}`);
}

export async function billboardSetup(typeId?: string, address?: any) {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  

  const billBoardAddress = await deployBillboard();
	console.log("billboard  deployed to:", billBoardAddress);
  
  //need to whitelist this contact 
  //await whitelistAssetType("0xF1745fc0B254A69000FEcA62F02B2Fe740a0C614", billBoardAddress);
  
  
    console.log("------------------ REGISTER BILLBOARD------------------")
    await registerBillBoard(billBoardAddress, 1043094, 104950);
    await registerBillBoard(billBoardAddress, 3492304, 194950);
    await registerBillBoard(billBoardAddress, 5043094, 234950);

}

billboardSetup()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
