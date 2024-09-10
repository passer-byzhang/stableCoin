import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 10,        
        details: {
          constantOptimizer: true,
        },
      },
    },
  },
  networks:{
    /*neoxtestnet: {
      url: "https://neoxt4seed1.ngd.network",
    },*/
    base: {
      url: "https://mainnet.base.org",
    },
  }
};

export default config;
