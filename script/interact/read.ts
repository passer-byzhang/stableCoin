import { ethers } from "hardhat";
import {config} from "../config.base";

async function vaults(nftId:number){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("VaultManager",config.addresses.stablecoin.VaultManager.addresses.proxy);
    const vaults = await dnft.getVaults(nftId);
    console.log("vaults:",vaults);
}

async function collatRatio(nftId:number){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("VaultManager",config.addresses.stablecoin.VaultManager.addresses.proxy);
    const collatRatio = await dnft.collatRatio(nftId);
    console.log("collatRatio:",collatRatio);
}

async function mintedDyad(nftId:number){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("DyadUpgradeable",config.addresses.stablecoin.Dyad.addresses.proxy);
    const mintedDyad = await dnft.mintedDyad(nftId);
    console.log("mintedDyad:",mintedDyad);
}

async function dyadTotalSupply(){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("DyadUpgradeable",config.addresses.stablecoin.Dyad.addresses.proxy);
    const mintedDyad = await dnft.totalSupply();
    console.log("dyadTotalSupply:",mintedDyad);
}

async function readVault(nftId:number){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const wethvault = await ethers.getContractAt("Vault",config.addresses.stablecoin.Vault.weth);
    let asset = await wethvault.id2asset(nftId);
    let assetPrice = await wethvault.assetPrice();
    console.log("asset:",asset);
    console.log("assetPrice:",assetPrice);

    const keorseneVault = await ethers.getContractAt("Vault",config.addresses.stablecoin.Vault.kerosene);
    asset = await keorseneVault.id2asset(nftId);
    assetPrice = await keorseneVault.assetPrice();
    console.log("asset:",asset);
    console.log("assetPrice:",assetPrice);
}

async function kerosenePrice(){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("KeroseneVault",config.addresses.stablecoin.Vault.kerosene);
    const price = await dnft.assetPrice();
    console.log("price:",price);
}

async function keroseneManagergetVaults(){
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const dnft = await ethers.getContractAt("KeroseneManager",config.addresses.stablecoin.KeroseneManager);
    const vaults = await dnft.getVaults();
    console.log("vaults:",vaults);
}

async  function tvl(){
    const weth = await ethers.getContractAt("ERC20Mock",config.addresses.WETH.addresses);
    const wethVaultBalance = await weth.balanceOf(config.addresses.stablecoin.Vault.weth);
    console.log("wethVaultBalance:",wethVaultBalance.toString());
    const wethVault = await ethers.getContractAt("Vault",config.addresses.stablecoin.Vault.weth);
    const wethAssetPrice = await wethVault.assetPrice();
    console.log("wethAssetPrice:",wethAssetPrice.toString());
    const kerosineDenominator = await ethers.getContractAt("KeroseneDenominatorV2",config.addresses.stablecoin.KeroseneDenominator);
    const denominator = await kerosineDenominator.denominator();
    console.log("denominator:",denominator.toString());
}

tvl();