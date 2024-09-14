import { ethers } from "hardhat";
import {config} from "../config.base";

async function transferTo(to:string){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("Kerosene",config.addresses.stablecoin.Kerosene.addresses);
    const tx = await dnft.connect(deployer).transfer(to,ethers.parseEther("100"));
    console.log("transfer txhash:", tx.hash);
}
transferTo("0x64C19ae379f00CBcB824F9F25a393eFB02987796");