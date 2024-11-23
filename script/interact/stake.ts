import { ethers } from "hardhat";
import { config } from "../config.tabi";

async function deposit(tokenId:number,stakerAddress:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const satker = await ethers.getContractAt("Staker",stakerAddress);
    const tx = await satker.connect(deployer).stake(tokenId);
    console.log("deposit txhash:", tx.hash);
}

async function info(user:string,stakerAddress:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const staker = await ethers.getContractAt("Staker",stakerAddress);
    const info = await staker.userInfo(user);
    console.log("info:", info);
}

async function withdraw(tokenId:number,stakerAddress:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const satker = await ethers.getContractAt("Staker",stakerAddress);
    const tx = await satker.connect(deployer).withdraw(tokenId);
    console.log("withdraw txhash:", tx.hash);
}

info("0x64C19ae379f00CBcB824F9F25a393eFB02987796","0xA2154E81030051C80106FFE6DC65a012fB46b902");

//deposit(100403,"0xA2154E81030051C80106FFE6DC65a012fB46b902")
//withdraw(100403,"0xA2154E81030051C80106FFE6DC65a012fB46b902")