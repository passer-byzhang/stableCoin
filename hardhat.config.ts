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
      accounts: [
        "af6b265e6e3b5a76b7dab1fc438c17f80c0dacbe401ce4014b5523f2f79aa770",
        "76591e4de92849e8989241b52e2306591e9bebd9d744999bc6eb068657fa5dbc",
      ],
      gasPrice: 253125000000,
      initialBaseFeePerGas: 8000000000,
    },*/
    base: {
      url: "https://mainnet.base.org",
      accounts: [
        "e580d9dc3d31f6ddaf4c19dad7fa9ab0ef0cec2108d1e2d05a08bc0edb320ed8",
        "d6298aaf14f9678f778e0cfbd6d3a87050935eb57dc0be11c14a1a671f6518e8"
      ]
    },
  }
};

export default config;
