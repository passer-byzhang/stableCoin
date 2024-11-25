import { ethers } from "hardhat";
import {config} from "../config.tabi";
async function setKeroseneManager(vault:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const KeroseneManager = await ethers.getContractAt("KeroseneManager",config.addresses.stablecoin.KeroseneManager);

    let   tx = await KeroseneManager.connect(deployer).add(vault);

    console.log("set vault  txhash:", tx.hash);
}


setKeroseneManager(config.addresses.stablecoin.Vault.usdd);