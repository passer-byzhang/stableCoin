import { ethers } from "hardhat";
import {config} from "../config.tabi";

async function mintDNftTo(to:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("DNftUpagradable",config.addresses.stablecoin.DNft.addresses.proxy);
    const tx = await dnft.connect(deployer).mintInsiderNft(to);
    console.log("mint DNft txhash:", tx.hash);
}

async function addDeposit(tokenId:number,vault:string,vaultManageAddress:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const vaultManager = await ethers.getContractAt("VaultManager",vaultManageAddress);
    const tx = await vaultManager.connect(deployer).add(tokenId,vault);
    console.log("addDeposit txhash:", tx.hash);

}

addDeposit(1,config.addresses.stablecoin.Vault.usdd,config.addresses.stablecoin.VaultManager.addresses.proxy);

