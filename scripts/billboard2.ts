import { ethers } from 'hardhat';
import { verify } from './verify';

async function main() {
    const Billboard = await ethers.getContractFactory('BillboardFactory');

    // Note: The BillboardFactory contract doesn't have a constructor that takes these parameters.
    // If these values are essential, modify the smart contract to accommodate them.
    const duration = 60 * 60 * 24; // 1 day
    const link = "https://api.dataponte.com/billboard/getDisplay";

    const billboard = await Billboard.deploy();
    await billboard.waitForDeployment();
    const billBoardAddress = await billboard.getAddress();

    console.log("----------------------------------------------------");
    console.log(`⛓️ Deploying Contract...`);
    console.log('Billboard address deployed to:', billBoardAddress);

    //we want to wait here a few seconds to make sure the contract is deployed
    await new Promise(r => setTimeout(r, 10000));
    await verify(billBoardAddress);  // This may not work correctly if the contract doesn't have the corresponding parameters

    console.log("Contract verified");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
