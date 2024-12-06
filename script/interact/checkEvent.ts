import { ethers } from "hardhat";
/*
const abi = [
    "event Liquidate(uint256,address,address,uint256)"];*/
const abi = [
        "event Withdraw(uint256,address,uint256)","event Liquidate(uint256,address,address,uint256)"];
  const provider = new ethers.JsonRpcProvider("https://rpc.eth.gateway.fm");
    const contract = new ethers.Contract(
        "0xB62bdb1A6AC97A9B70957DD35357311e8859f0d7",
        abi,provider
        );
let filter = contract.filters.Liquidate;
console.log(filter);

  const init = async () => {
    await provider.on("block", async () => {
      // This line of code listens to the block mining and every time a block is mined, it will return blocknumber.
      const transferEvent = await contract.queryFilter(filter, -1000);
  
      console.log(transferEvent);
    });
  };
  
  init().catch((err) => {
    console.log(err);
    process.exit(1);
  });
  