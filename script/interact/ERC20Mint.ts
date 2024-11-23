import { ethers } from "hardhat";
import {config} from "../config.tabi";

async function mint(token:string,to:string,amount:bigint){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const ERC20 = await ethers.getContractAt("ERC20Mock",token);
    const tx = await ERC20.connect(deployer).mint(to,amount);
    console.log("mint txhash:", tx.hash);
}

//mint("0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8","0x48dDC29597d4074218ae3EdD0c85047Bfd321929",ethers.parseEther("100"))