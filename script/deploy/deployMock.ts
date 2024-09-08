import { ethers } from "hardhat";

export async function deployTokenA(){
    const [deployer, proxyAdmin] = await ethers.getSigners();
    //deploy dnft impl
    const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
    const token = await ERC20Mock.connect(deployer).deploy("TokenA","TokenA");
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();
    console.log("tokenA deployed to:", tokenAddress);
}


export async function deployMockOracle(price:number){
    const [deployer, proxyAdmin] = await ethers.getSigners();
    //deploy dnft impl
    const OracleMock = await ethers.getContractFactory("OracleMock");
    const oracle = await OracleMock.connect(deployer).deploy(price);
    await oracle.waitForDeployment();
    const oracleAddress = await oracle.getAddress();
    console.log("oracle deployed to:", oracleAddress);
}
deployMockOracle(1000000);