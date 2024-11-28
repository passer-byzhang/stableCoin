import { ethers } from "hardhat";
import {config} from "../config.tabi";
import {abi} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
import {abi as poolAbi} from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";

async function createPool(){

    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const Factory = await ethers.getContractAt(abi,config.addresses.swap.factory);

    let pool = await Factory.createPool(
        config.addresses.usdc.addresses,
        config.addresses.stablecoin.Dyad.addresses.proxy,
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
    const tx = await pool.initialize(79228162514264337593543950336n);
    console.log("init pool txhash:", tx.hash);
}

getPoolAddress(        
    config.addresses.usdc.addresses,
    config.addresses.stablecoin.Dyad.addresses.proxy);
//0x977af32042586C93dB6b6a358d86D9DB62bB1d85

//createPool();
initPool("0x0D4ca7c9335FdA30eFbE3bFD4EfC4b60D74280E2");
//tokenA deployed to: 0x849dFA3d939CCA38E0DE0618a361d4343C3186f0
//tokenB deployed to: 0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8