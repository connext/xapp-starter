import dotenv from "dotenv";
import dotenvExpand from 'dotenv-expand';
const envConfig = dotenv.config();
dotenvExpand.expand(envConfig);

import { HardhatUserConfig } from "hardhat/types";

import "./tasks/transfer";
import "./tasks/updateGreeting";
import "./tasks/updateGreetingAuthenticated";
import "./tasks/startPingPong";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    goerli: {
      accounts: [ process.env.PRIVATE_KEY! ],
      chainId: 5,
      url: process.env.ORIGIN_RPC_URL
    },
  },
  paths: {
    sources: "./src",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};

export default config;

