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
      url: "https://rpc.testnetv2.tabichain.com",
      accounts: ["e5ea9fcc47953aeb4a3efb29a341ecbce9058397a9c9626a38c9e9d5cb19f236","844538855cab95c979fd866241bef39e791b02ed04949bd8c38906e605f68c42"]
  }
}
};

export default config;
