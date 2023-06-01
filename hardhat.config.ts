import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-contract-sizer";
import { HardhatUserConfig, task } from "hardhat/config";

// require("dotenv").config();
// const { PRIVATE_KEY } = process.env;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    // mchMainnet: {
    //   url: "https://rpc.oasys.mycryptoheroes.net/",
    //   chainId: 29548,
    //   accounts: [PRIVATE_KEY as string],
    //   gasPrice: 0,
    // },
    // mchTestnet: {
    //   url: "https://rpc.oasys.sand.mchdfgh.xyz/",
    //   chainId: 420,
    //   accounts: [PRIVATE_KEY as string],
    //   gasPrice: 0,
    // },
    // sandverse: {
    //   url: "https://rpc.sandverse.oasys.games/",
    //   chainId: 20197,
    //   accounts: [PRIVATE_KEY as string],
    //   gasPrice: 0,
    // },
  },
};

export default config;
