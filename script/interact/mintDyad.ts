import { ethers } from "hardhat";
import {config} from "../config.tabi";

async function getVaultsValues(vaultmanager:string,tokenId:number){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const ERC20 = await ethers.getContractAt("VaultManager",vaultmanager);
    const tx = await ERC20.connect(deployer).getVaultsValues(tokenId);
    console.log(tx);

}

async function mintDyad(vaultmanager:string,id:bigint,amount:bigint){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const ERC20 = await ethers.getContractAt("VaultManager",vaultmanager);
    const tx = await ERC20.connect(deployer).mintDyad(id,amount,deployer.address);
    console.log("mint txhash:", tx.hash);
}

mintDyad(config.addresses.stablecoin.VaultManager.addresses.proxy,0n,10000000n)
//getVaultsValues(config.addresses.stablecoin.VaultManager.addresses.proxy,0)