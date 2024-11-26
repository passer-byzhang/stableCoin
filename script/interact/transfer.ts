import { ethers } from "hardhat";
import {config} from "../config.tabi";

async function transferTo(to:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("Kerosene",config.addresses.stablecoin.Kerosene.addresses);
    const tx = await dnft.connect(deployer).transfer(to,ethers.parseEther("100"));
    console.log("transfer txhash:", tx.hash);
}
//transferTo("0x616dB1933e4CbE719394A21b6E08567316666952");