import { ethers } from "hardhat";
import {config} from "../config.base";

async function mintDNftTo(to:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("DNftUpagradable",config.addresses.stablecoin.DNft.addresses.proxy);
    const tx = await dnft.connect(deployer).mintNft(to,{value:ethers.parseEther("0.000011")});
    console.log("mint DNft txhash:", tx.hash);
}

mintDNftTo("0x64C19ae379f00CBcB824F9F25a393eFB02987796")