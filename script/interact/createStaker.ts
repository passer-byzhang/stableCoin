import { ethers } from "hardhat";
import { config } from "../config.tabi";
async function deployStakerFactory() {
    const [deployer] = await ethers.getSigners();
    const StakerFactory = await ethers.getContractFactory("StakerFactory");
    const stakerFactory = await StakerFactory.connect(deployer).deploy(

        config.addresses.stablecoin.Kerosene.addresses,
        config.addresses.swap.nonfungiblePositionManager,
        "0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8",
        "0x849dFA3d939CCA38E0DE0618a361d4343C3186f0",
        deployer.address
    );
    await stakerFactory.waitForDeployment();

    console.log("StakerFactory deployed to:", stakerFactory.target);
    //0xC47191328B45b97Ff54ae1bC553b0728e960f75a
}


async function createStaker() {
    const [deployer] = await ethers.getSigners();
    const StakerFactory = await ethers.getContractAt("StakerFactory", config.addresses.stablecoin.StakerFactory);
    const tx = await StakerFactory.connect(deployer).createStaker(
        3000,
        -960,
        960,
        1732858254,
        1733031054,
        100
    );
    console.log("createStaker txhash:", tx.hash);
}
async function getStaker() {
    const [deployer] = await ethers.getSigners();
    const StakerFactory = await ethers.getContractAt("StakerFactory", config.addresses.stablecoin.StakerFactory);
    const staker = await StakerFactory.connect(deployer).stakers(3);
    console.log(staker);
    //0xA2154E81030051C80106FFE6DC65a012fB46b902
}
//getStaker();
async function poolInfo() {
    const [deployer] = await ethers.getSigners();
    const StakerFactory = await ethers.getContractAt("Staker", "0xaf4c1EE87f2E54FDFd57Db89A40E1A6Bd237C184");
    const pool = await StakerFactory.connect(deployer).poolInfo();
    console.log(pool);
    //0x977af32042586C93dB6b6a358d86D9DB62bB1d85
}



async function getInfo(user:string){
    const [deployer] = await ethers.getSigners();
    const StakerFactory = await ethers.getContractAt("Staker", "0x93D2874708d30525D3E931Bd5206524CE0c176Ff");
    const pool = await StakerFactory.connect(deployer).userInfo(user);
    console.log(pool);
}
poolInfo();
//getStaker();
//createStaker();
//deployStakerFactory();
//tokenA deployed to: 0x849dFA3d939CCA38E0DE0618a361d4343C3186f0
//tokenB deployed to: 0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8
getInfo("0x616dB1933e4CbE719394A21b6E08567316666952")