import { ethers } from "hardhat";
import { config } from "../config.tabi";
import {abi} from "@uniswap/v3-periphery/artifacts/contracts/interfaces/INonfungiblePositionManager.sol/INonfungiblePositionManager.json";
async function addLiquidity() {
  const tokenA = "0x849dFA3d939CCA38E0DE0618a361d4343C3186f0";
  const tokenB = "0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8";
  const nonfungiblePositionManager = await ethers.getContractAt(
    "INonfungiblePositionManager",
    config.addresses.swap.nonfungiblePositionManager
  );
  const [deployer] = await ethers.getSigners();
  

  console.log("approved tokenB");
  const mintParams = {
    token0: tokenB,
    token1: tokenA,
    fee: 3000,
    tickLower: -60000,
    tickUpper: 60000,
    amount0Desired: ethers.parseEther("10"),
    amount1Desired: ethers.parseEther("10"),
    amount0Min: 0,
    amount1Min: 0,
    recipient: deployer.address,
    deadline: 1832283368 + 1000000,
  };
  const hash = await nonfungiblePositionManager
    .connect(deployer)
    .mint(mintParams);
  console.log("add liquidity txhash:", hash.hash);
}

async function getTokenId(user:string){
    const nonfungiblePositionManager = await ethers.getContractAt(
        "INonfungiblePositionManager",
        config.addresses.swap.nonfungiblePositionManager
      );
    const tokenId = await nonfungiblePositionManager.tokenOfOwnerByIndex(user,0);
    console.log("tokenId:", tokenId);
}


async function getTokenOwner(tokenId:number){
    const nonfungiblePositionManager = await ethers.getContractAt(
        "INonfungiblePositionManager",
        config.addresses.swap.nonfungiblePositionManager
      );
    const owner = await nonfungiblePositionManager.ownerOf(tokenId);
    console.log("owner:", owner);
}

async function approve(tokenId:number,contract:string){
    const nonfungiblePositionManager = await ethers.getContractAt(
        "INonfungiblePositionManager",
        config.addresses.swap.nonfungiblePositionManager
      );
    await nonfungiblePositionManager.approve(contract,tokenId);
    console.log("approved");

}

async function transferFrom(tokenId:number,from:string,to:string){
    const nonfungiblePositionManager = await ethers.getContractAt(
        "INonfungiblePositionManager",
        config.addresses.swap.nonfungiblePositionManager
      );
    await nonfungiblePositionManager.transferFrom(from,to,tokenId);
    console.log("transfered");

}
//transferFrom(100404,"0x48dDC29597d4074218ae3EdD0c85047Bfd321929","0x64C19ae379f00CBcB824F9F25a393eFB02987796");
//approve(100404,"0xA2154E81030051C80106FFE6DC65a012fB46b902");
getTokenOwner(100404);
//tokenId: 100403n
//addLiquidity();
//tokenA deployed to: 0x849dFA3d939CCA38E0DE0618a361d4343C3186f0
//tokenB deployed to: 0x04CC49a74263Dc4eF9cA855f541797D9b86b04B8
