import { ethers } from "hardhat";
import {config} from "../config.tabi";
import {abi} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import {abi as poolAbi} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";

async function createPool(){

    const [deployer] = await ethers.getSigners();
    const token = await ethers.getContractFactory("ERC20Mock");
    const A = await token.connect(deployer).deploy("USD1","USD1");
    await A.waitForDeployment();
    const B = await token.connect(deployer).deploy("USD2","USD2");
    await B.waitForDeployment();
    const tokenAAddress = await A.getAddress();
    const tokenBAddress = await B.getAddress();
    console.log("tokenA deployed to:", tokenAAddress);
    console.log("tokenB deployed to:", tokenBAddress);
    //deploy dyad impl
    const Factory = await ethers.getContractAt(abi,config.addresses.swap.factory);

    let pool = await Factory.createPool(
        tokenAAddress,
        tokenBAddress,
        3000
    );
    console.log("create pool txhash:", pool);
}

async function getPoolAddress(tokenA:string,tokenB:string){
    const Factory = await ethers.getContractAt(abi,config.addresses.swap.factory);
    let poolAddress = await Factory.getPool(tokenA,tokenB,3000);
    console.log("pool address:", poolAddress);
    const pool = await ethers.getContractAt(poolAbi,poolAddress);
    const x = await pool.slot0();
    console.log("slot0:", x);
}


async function initPool(poolAddress:string){
    //const [deployer] = await ethers.getSigners();
    const pool = await ethers.getContractAt(poolAbi,poolAddress);
    const x = 2n ** 96n;
    console.log("x:", x);
    const tx = await pool.initialize(79228162514264337593543950336n);
    console.log("init pool txhash:", tx.hash);
}

getPoolAddress("0x849dFA3d939CCA38E0DE0618a361d4343C3186f0","0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8");
//0x977af32042586C93dB6b6a358d86D9DB62bB1d85

//createPool();
//initPool("0x977af32042586C93dB6b6a358d86D9DB62bB1d85");
//tokenA deployed to: 0x849dFA3d939CCA38E0DE0618a361d4343C3186f0
//tokenB deployed to: 0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8