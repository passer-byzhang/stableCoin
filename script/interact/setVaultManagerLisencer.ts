import { ethers } from "hardhat";
import {config} from "../config.base";
async function setVaultManagerLisencer(vaultManager:string,isLisence:boolean){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const Vault = await ethers.getContractAt("Licenser",config.addresses.stablecoin.Licenser.addresses);
    let tx;
    if(isLisence==true){
         tx = await Vault.connect(deployer).add(vaultManager);

    }else{
         tx = await Vault.connect(deployer).remove(vaultManager);
    }
    
    console.log("set vault manager lisencer txhash:", tx.hash);
}


setVaultManagerLisencer(config.addresses.stablecoin.VaultManager.addresses.proxy,true);