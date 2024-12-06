import { ethers } from "hardhat";
import {config} from "../config.tabi";

async function transferTo(to:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("Kerosene",config.addresses.stablecoin.Kerosene.addresses);
    const tx = await dnft.connect(deployer).transfer(to,ethers.parseEther("100"));
    console.log("transfer txhash:", tx.hash);
}

async function approve(token:string,to:string,amount:bigint){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("ERC20Mock",token);
    const tx = await dnft.connect(deployer).approve(to,amount);
    console.log("transfer txhash:", tx.hash);
}


approve(config.addresses.usdd.addresses,config.addresses.stablecoin.VaultManager.addresses.proxy,ethers.parseEther("100"));
//transferTo(config.addresses.stablecoin.StakerFactory);