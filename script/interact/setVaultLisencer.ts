import { ethers } from "hardhat";
import {config} from "../config.base";
async function setVaultLisencer(vault:string,isKero:boolean,isLisence:boolean){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const Vault = await ethers.getContractAt("VaultLicenser",config.addresses.stablecoin.VaultLicenser.addresses);
    let tx;
    if(isLisence==true){
         tx = await Vault.connect(deployer).add(vault,isKero);

    }else{
         tx = await Vault.connect(deployer).remove(vault);
    }
    
    console.log("set vault lisencer txhash:", tx.hash);
}


//setVaultLisencer(config.addresses.stablecoin.Vault.kerosene,true,true);