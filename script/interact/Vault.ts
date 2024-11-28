import { ethers } from "hardhat";
import {config} from "../config.tabi";

async function getUsdValue(vault:string,tokenId:bigint){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const ERC20 = await ethers.getContractAt("Vault",vault);
    const tx = await ERC20.connect(deployer).getUsdValue(tokenId);
    console.log(tx);

}
async function deposit(vaultmanager:string,vault:string,amount:bigint){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const ERC20 = await ethers.getContractAt("VaultManager",vaultmanager);
    const tx = await ERC20.connect(deployer).deposit(0,vault,amount);
    console.log("mint txhash:", tx.hash);
}



async function getVaults(vaultmanager:string,id:bigint){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const ERC20 = await ethers.getContractAt("VaultManager",vaultmanager);
    const tx = await ERC20.connect(deployer).getVaults(id);
    console.log(tx);

}


async function removeVault(vaultmanager:string,vault:string,id:bigint){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const ERC20 = await ethers.getContractAt("VaultManager",vaultmanager);
    const tx = await ERC20.connect(deployer).remove(id,vault);
    console.log("mint txhash:", tx.hash);
}


//deposit(config.addresses.stablecoin.VaultManager.addresses.proxy,config.addresses.stablecoin.Vault.usdd,ethers.parseEther("10"))
//getUsdValue(config.addresses.stablecoin.Vault.usdd,0n)
//getVaults(config.addresses.stablecoin.VaultManager.addresses.proxy,1n)
//removeVault(config.addresses.stablecoin.VaultManager.addresses.proxy,"0xe01e37fA9218B480BC922613B2489ea54f23F2E2",1n)