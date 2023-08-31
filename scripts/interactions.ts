import { ethers } from 'hardhat';
import { verify } from './verify';

async function main() {
    const Interactions = await ethers.getContractFactory('BillboardInteraction');


    const rallyToken = "0x1C7312Cb60b40cF586e796FEdD60Cf243286c9E9"; //rally tokens
    const trustedForwarder = "0x499D418D4493BbE0D9A8AF3D2A0768191fE69B87"; //rally forwarder

    const interactionContract = await Interactions.deploy(rallyToken, trustedForwarder);
    await interactionContract.waitForDeployment();
    const interactionAddress = await interactionContract.getAddress();

    console.log("----------------------------------------------------");
    console.log(`⛓️ Deploying Contract...`);
    console.log('Billboard address deployed to:', interactionAddress);

    //we want to wait here a few seconds to make sure the contract is deployed
    await new Promise(r => setTimeout(r, 10000));
    await verify(interactionAddress, [rallyToken, trustedForwarder]);  // This may not work correctly if the contract doesn't have the corresponding parameters

    console.log("Contract verified");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
