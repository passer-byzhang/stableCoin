import { ethers } from "hardhat";
import {config} from "../config.tabi";
async function addKeroseneManager(vault:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const KeroseneManager = await ethers.getContractAt("KeroseneManager",config.addresses.stablecoin.KeroseneManager);

    let   tx = await KeroseneManager.connect(deployer).add(vault);

    console.log("set vault  txhash:", tx.hash);
}

async function removeKeroseneManager(vault:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const KeroseneManager = await ethers.getContractAt("KeroseneManager",config.addresses.stablecoin.KeroseneManager);

    let   tx = await KeroseneManager.connect(deployer).remove(vault);

    console.log("set vault  txhash:", tx.hash);
}

addKeroseneManager(config.addresses.stablecoin.Vault.wtabi);