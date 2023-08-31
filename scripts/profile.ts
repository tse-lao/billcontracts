import { ethers } from 'hardhat';
import { verify } from './verify';

async function main() {
    const ProfileContract = await ethers.getContractFactory('UserProfile');
    
    const trustedForwarder = "0x499D418D4493BbE0D9A8AF3D2A0768191fE69B87" ; //rally forwarder
    
    const profile = await ProfileContract.deploy(trustedForwarder);
    await profile.waitForDeployment();
    const profileAddress = await profile.getAddress();

    console.log("=======================================");
    console.log(`⛓️ Deploying Contract...`);
    console.log('Profile address:', profileAddress);

    //we want to wait here a few seconds to make sure the contract is deployed
    await new Promise(r => setTimeout(r, 10000));
    await verify(profileAddress, [trustedForwarder]);  

    console.log("We have verified the contracts congratulations ");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
