import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.27",
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
    tabiTestnet:{
      url: "https://rpc.testnetv2.tabichain.com",  }
}
};

export default config;
