import { ethers } from "hardhat";
import {config} from "../config.tabi";
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


async function getVaultLisencer(vault:string){
     const [deployer] = await ethers.getSigners();
     //deploy dyad impl
     const Vault = await ethers.getContractAt("VaultLicenser",config.addresses.stablecoin.VaultLicenser.addresses);
     let tx = await Vault.connect(deployer).licenses(vault);
     console.log(tx);
}

async function main(){
     await setVaultLisencer(config.addresses.stablecoin.Vault.wtabi,false,true);
     await setVaultLisencer(config.addresses.stablecoin.Vault.usdd,false,true);
     await setVaultLisencer(config.addresses.stablecoin.Vault.kerosene,true,true);
     //getVaultLisencer("0x5eC36e4e6389390e68A57a8d2423d0DDF90eE643");
}
//main();