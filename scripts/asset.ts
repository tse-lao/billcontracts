// scripts/deploy_asset_registry.js

const hre = require("hardhat");

async function deployAssetRegistry() {
  console.log("deployAsset starting... ");
  const AssetContract = await hre.ethers.getContractFactory("AssetRegistry");
  const deployAsset = await AssetContract.deploy();
  await deployAsset.waitForDeployment();
  const assetRegistryAddress = await deployAsset.getAddress();
  console.log(`Asset Registry deployed to: ${assetRegistryAddress}`);
  return assetRegistryAddress;
}

// contract address as parameter
async function addAssetType(assetRegistry: any) {
  console.log("Addding asset type starting... ");

  const assetFactory = await hre.ethers.getContractFactory("AssetRegistry");

  const assetInteractor = await assetFactory.attach(assetRegistry);
  const assetTypeName = "Billboards";
  const assetTypeDescription = "Deployed Contract for billboards";
  const typeId = await assetInteractor.addAssetType(
    assetTypeName,
    assetTypeDescription
  );
  console.log(
    `Asset Type added: Name = ${assetTypeName}, Description = ${assetTypeDescription}`
  );
  return typeId;
}

async function whitelistAssetType(assetRegistry: any, billboardAddress: any) {
  const assetFactory = await hre.ethers.getContractFactory("AssetRegistry");
  const assetInteractor = await assetFactory.attach(assetRegistry);

  await assetInteractor.setApprovedContract(billboardAddress, true);
}


export async function deployBillboard(typeId: any, address: any, timeslots: any) {
    const Billboard = await hre.ethers.getContractFactory("Billboard");
    const billBoard = await Billboard.deploy(address, 1, timeslots, { gasLimit: 100000000 });
    await billBoard.waitForDeployment();
    const billBoardAddress = await billBoard.getAddress();
    console.log(`Asset Registry deployed to: ${billBoardAddress}`)
    return billBoardAddress;
  }
  


export async function createBillboard(address:any) {
    
    const addressFactory = await hre.ethers.getContractFactory(
        "Billboard"
    );
    
    const deployedContract =
    await addressFactory.attach(
        address
    );
  const metadataURI = "ipfs://samplemetadata"; // Placeholder URI for testing
  console.log("createBillboard starting... ")
  await deployedContract.registerBillboard(0, 0, metadataURI); // Using type ID and location ID 0 (the ones we just added)
  console.log(`Asset registered with Metadata URI: ${metadataURI}`);
}

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("- 📝 DEPLOYING ASSET REGISTRY ------------------");
  const assetRegistry = await deployAssetRegistry();
  console.log("assetRegistry deployed to:", assetRegistry);

  console.log("- ♷ ADDING ASSET TYPE ------------------");
  const typeId = await addAssetType(assetRegistry);

    console.log("- ® REGISTER BILLBOARD------------------");
    const timeslots = "0xd89329A3DF1a8da9B4ec8F31C29D7589cf046C9a"
  const billboardAddress = await deployBillboard(typeId, assetRegistry, timeslots);

  console.log("- 🏃🏻‍♂️ RUNNING BILLBOARD------------------");
  await whitelistAssetType(assetRegistry, billboardAddress);

  console.log("- ⏰ register billboard");
  await createBillboard(billboardAddress); 
  // Register an asset
  console.log("- 🚀 FINISHED DEPLOYING CONTRACT AND BILLBOARD -----");
  //  await verify(assetRegistry);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
