import { ethers } from "hardhat";
import {config} from "../config.tabi";
import {deployMockOracle,deployTokenA} from "./deployMock"
 // deploy dnft contract

async function deployStakerFactory(){
  const [deployer, proxyAdmin] = await ethers.getSigners();
  //deploy dnft impl
  const StakerFactory = await ethers.getContractFactory("StakerFactory");
  const stakerFactory = await StakerFactory.connect(deployer).deploy(
    config.addresses.stablecoin.Kerosene.addresses,
    config.addresses.stablecoin.nonfungibleTokenPositionManager.addresses,
    config.addresses.stablecoin.Dyad.addresses.proxy,
    config.addresses.usdd.addresses,
    deployer.address
  );
  await stakerFactory.waitForDeployment();
  const stakerFactoryAddress = await stakerFactory.getAddress();
  console.log("StakerFactory deployed to:", stakerFactoryAddress);
}



async function deployDNft() {
  const [deployer, proxyAdmin] = await ethers.getSigners();
  //deploy dnft impl
  const DNFT = await ethers.getContractFactory("DNftUpagradable");
  const dnft = await DNFT.connect(deployer).deploy();
  await dnft.waitForDeployment();
  const dnftAddress = await dnft.getAddress();
  console.log("DNFT deployed to:", dnftAddress);

  //deploy dnft proxy
  const DNFTProxy = await ethers.getContractFactory("PProxy");
  const dnftProxy = await DNFTProxy.deploy(dnftAddress, proxyAdmin.address);
  await dnftProxy.waitForDeployment();
  console.log("DNFTProxy deployed to:", await dnftProxy.getAddress());

  //initialize dnft
  const dnftInstance = await ethers.getContractAt(
    "DNftUpagradable",
    await dnftProxy.getAddress()
  );
  await dnftInstance.connect(deployer).initialize();
  console.log("DNFT initialized");
  //deploy
}

async function deployLicenser() {
  //deploy dnft impl
  const Licenser = await ethers.getContractFactory("Licenser");
  const licenser = await Licenser.deploy();
  await licenser.waitForDeployment();
  const licenserAddress = await licenser.getAddress();
  console.log("Licenser deployed to:", licenserAddress);

  const VaultLicenser = await ethers.getContractFactory("VaultLicenser");
  const vaultLicenser = await VaultLicenser.deploy();
  await vaultLicenser.waitForDeployment();
  const vaultLicenserAddress = await vaultLicenser.getAddress();
  console.log("VaultLicenser deployed to:", vaultLicenserAddress);
}

async function deployDyad(licenserAddress: string) {
  const [deployer, proxyAdmin] = await ethers.getSigners();
  //deploy dyad impl
  const Dyad = await ethers.getContractFactory("DyadUpgradeable");
  const dyad = await Dyad.connect(deployer).deploy();
  await dyad.waitForDeployment();
  const dyadAddress = await dyad.getAddress();
  console.log("Dyad deployed to:", dyadAddress);

  //deploy dyad proxy
  const DyadProxy = await ethers.getContractFactory("PProxy");
  const dyadProxy = await DyadProxy.deploy(dyadAddress, proxyAdmin.address);
  await dyadProxy.waitForDeployment();
  console.log("DyadProxy deployed to:", await dyadProxy.getAddress());

  //initialize dyad
  const dyadInstance = await ethers.getContractAt(
    "DyadUpgradeable",
    await dyadProxy.getAddress()
  );
  await dyadInstance.connect(deployer).initialize(licenserAddress);
  console.log("DNFT initialized");
}

async function deployVaultManager() {
  const [deployer, proxyAdmin] = await ethers.getSigners();
  //deploy dyad impl
  const VaultManager = await ethers.getContractFactory("VaultManager");
  const vaultManager = await VaultManager.connect(deployer).deploy();
  await vaultManager.waitForDeployment();
  const vaultManagerAddress = await vaultManager.getAddress();
  console.log("VaultManager deployed to:", vaultManagerAddress);

  const Proxy = await ethers.getContractFactory("PProxy");
  const vaultManagerProxy = await Proxy.deploy(vaultManagerAddress, proxyAdmin.address);
  await vaultManagerProxy.waitForDeployment();
  console.log("VaultManagerProxy deployed to:", await vaultManagerProxy.getAddress());
}

async function initializeVaultManage(
  vaultManager: string,
  dNft: string,
  _dyad: string,
  _vaultLicenser: string
) {

  const [deployer, proxyAdmin] = await ethers.getSigners();
  const vaultManagerInstance = await ethers.getContractAt("VaultManager", vaultManager);
  await vaultManagerInstance.connect(deployer).initialize( dNft, _dyad, _vaultLicenser);
  console.log("VaultManager initialized");
}

async function deployVault(
  vaultManager: string,
  asset: string,
  oracle: string
) {
  const [deployer] = await ethers.getSigners();
  //deploy dyad impl
  const Vault = await ethers.getContractFactory("Vault");
  const vault = await Vault.connect(deployer).deploy(
    vaultManager,
    asset,
    oracle
  );
  await vault.waitForDeployment();
  const vaultAddress = await vault.getAddress();
  console.log("Vault deployed to:", vaultAddress);
}

async function depolyKeroseneVault(
    vaultManager: string,
    kerosene: string,
    dyad: string,
    keroseneManager: string,
    oracle: string,
    kerosineDenominator:string
  ) {
    const [deployer] = await ethers.getSigners();
    //deploy dyad impl
    const KeroseneVault = await ethers.getContractFactory("KeroseneVault");
    const keroseneVault = await KeroseneVault.connect(deployer).deploy(
        vaultManager,
        kerosene, 
        dyad,
        keroseneManager, 
        oracle, 
        kerosineDenominator
    );
    await keroseneVault.waitForDeployment();
    const vaultAddress = await keroseneVault.getAddress();
    console.log("KeroseneVault deployed to:", vaultAddress);
  }

async function deployDyadXP(
  vaultManager: string,
  keroseneVault: string,
  dnft: string
) {
  const [deployer] = await ethers.getSigners();
  //deploy dyad impl
  const DyadXP = await ethers.getContractFactory("DyadXP");
  const dyadXP = await DyadXP.connect(deployer).deploy(
    vaultManager,
    keroseneVault,
    dnft
  );
  await dyadXP.waitForDeployment();
  const dyadXPAddress = await dyadXP.getAddress();
  console.log("DyadXP deployed to:", dyadXPAddress);

    //deploy dyad proxy

}

async function initializeDyadXP(dyadXP: string) {
    const [deployer] = await ethers.getSigners();
    const dyadXPInstance = await ethers.getContractAt("DyadXP", dyadXP);
    await dyadXPInstance.connect(deployer).initialize(deployer.address);
    console.log("DyadXP initialized");
}


async function setKerosene( keroseneVault: string,DyadXP:string,vaultManager:string){ 
    const [deployer] = await ethers.getSigners();
    const vaultManagerInstance = await ethers.getContractAt("VaultManager", vaultManager);
    await vaultManagerInstance.connect(deployer).setKerosene(keroseneVault,DyadXP);
    console.log("Kerosene set");
}

async function deployKerosene(){
    const [deployer, ] = await ethers.getSigners();
    //deploy dnft impl
    const Kerosene = await ethers.getContractFactory("Kerosene");
    const kerosene = await Kerosene.connect(deployer).deploy();
    await kerosene.waitForDeployment();
    const keroseneAddress = await kerosene.getAddress();
    console.log("Kerosene deployed to:", keroseneAddress);
}
async function KeroseneDenominatorV2
(
 kerosene:string,
aexcludes:string[]){
    const [deployer, ] = await ethers.getSigners();
    //deploy dnft impl
    const KeroseneDenominatorV2 = await ethers.getContractFactory("KeroseneDenominatorV2");
    const keroseneDenominatorV2 = await KeroseneDenominatorV2.connect(deployer).deploy(
        kerosene,
        deployer.address,
        aexcludes
    );
    await keroseneDenominatorV2.waitForDeployment();
    const keroseneDenominatorV2Address = await keroseneDenominatorV2.getAddress();
    console.log("KeroseneDenominatorV2 deployed to:", keroseneDenominatorV2Address);
}

async function deployKeroseneManager(){
    const [deployer, ] = await ethers.getSigners();
    //deploy dnft impl
    const KeroseneManager = await ethers.getContractFactory("KeroseneManager");
    const keroseneManager = await KeroseneManager.connect(deployer).deploy();
    await keroseneManager.waitForDeployment();
    const keroseneManagerAddress = await keroseneManager.getAddress();
    console.log("KeroseneManager deployed to:", keroseneManagerAddress);
}





async function main(){
    //1. deploy DNFT
    //await deployDNft();
    //2. deploy Licenser
    //await deployLicenser();
    //3. deploy Dyad
    //await deployDyad(config.addresses.stablecoin.Licenser.addresses);
    //4. deploy kerosene, keorsene oracle
    //await deployKerosene();
    //await deployMockOracle(1000000);
    //5. deploy VaultManager
    //await deployVaultManager();
    //6. deploy dai and dai oracle
    //await deployTokenA();
   
    //7. deploy weth vault
    /*await deployVault(config.addresses.stablecoin.VaultManager.addresses.proxy,
        config.addresses.usdd.addresses,
        config.addresses.chainlink.usdd)*/
    //8. deploy keorsene vault
    //await depolyKeroseneVault(config.addresses.stablecoin.VaultManager.addresses.proxy, config.addresses.stablecoin.Kerosene.addresses, config.addresses.stablecoin.Oracle.kerosene)
    //9. deploy dyadxp
    //await deployDyadXP(config.addresses.stablecoin.VaultManager.addresses.proxy, config.addresses.stablecoin.Vault.kerosene, config.addresses.stablecoin.DNft.addresses.proxy)
    //10. initialize vault manager
    /*await initializeVaultManage(
        config.addresses.stablecoin.VaultManager.addresses.proxy,
        config.addresses.stablecoin.DNft.addresses.proxy,
        config.addresses.stablecoin.Dyad.addresses.proxy,
        config.addresses.stablecoin.VaultLicenser.addresses
    )*/
    //11. configure vault manager
    //deploy KeroseneDenominatorV2
    //await KeroseneDenominatorV2(config.addresses.stablecoin.Kerosene.addresses, [])
    //deploy KeroseneManager
    //await deployKeroseneManager()
    //deploy KeroseneVault
    /*await depolyKeroseneVault(
        config.addresses.stablecoin.VaultManager.addresses.proxy,
        config.addresses.stablecoin.Kerosene.addresses,
        config.addresses.stablecoin.Dyad.addresses.proxy,
        config.addresses.stablecoin.KeroseneManager,
        config.addresses.stablecoin.Oracle.kerosene,
        config.addresses.stablecoin.KeroseneDenominator
    )*/
    //await initializeDyadXP(config.addresses.stablecoin.DyadXP)
    //await setKerosene(config.addresses.stablecoin.Vault.kerosene,config.addresses.stablecoin.DyadXP,config.addresses.stablecoin.VaultManager.addresses.proxy);
    await deployStakerFactory();
    /*await deployVault(
      config.addresses.stablecoin.VaultManager.addresses.proxy,
      config.addresses.usdd.addresses,
      config.addresses.chainlink.usdd
    );


    await deployVault(
      config.addresses.stablecoin.VaultManager.addresses.proxy,
      config.addresses.wtabi.addresses,
      config.addresses.chainlink.wtabi
    );*/
  }
main();