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
    const StakerFactory = await ethers.getContractAt("StakerFactory", "0xC47191328B45b97Ff54ae1bC553b0728e960f75a");
    await StakerFactory.connect(deployer).createStaker(
        3000,
        -60000,
        60000,
        1732348760,
        1739877903,
        100
    );
}
async function getStaker() {
    const [deployer] = await ethers.getSigners();
    const StakerFactory = await ethers.getContractAt("StakerFactory", "0xC47191328B45b97Ff54ae1bC553b0728e960f75a");
    const staker = await StakerFactory.connect(deployer).stakers(1);
    console.log(staker);
    //0xA2154E81030051C80106FFE6DC65a012fB46b902
}
//getStaker();

createStaker();
//deployStakerFactory();
//tokenA deployed to: 0x849dFA3d939CCA38E0DE0618a361d4343C3186f0
//tokenB deployed to: 0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8