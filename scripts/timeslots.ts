import { ethers } from 'hardhat';
// import { deploymentAddressesBuilder } from './util';
import { verify } from './verify';



async function main() {

    console.log("----------------------------------------------------");
  const TimeSlotAds = await ethers.getContractFactory('TimeslotAds');
  console.log(`⛓️ Deploying Contract...`);
  const deployedContract = await TimeSlotAds.deploy();
  await deployedContract.waitForDeployment();
  const contractAddress = await deployedContract.getAddress();
  




  console.log('checkMade deployed deployed to:', contractAddress);




  await verify(contractAddress)


  console.log("Contract verified")

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
