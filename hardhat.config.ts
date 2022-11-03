
import { HardhatUserConfig } from "hardhat/types";
import { config as dotenvConfig } from "dotenv";

import "./tasks/simpleBridge";
import "./tasks/hello";
import "./tasks/helloAuthenticated";
import "./tasks/pingPong";

dotenvConfig();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.11",
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    goerli: {
      accounts: [ process.env.PRIVATE_KEY! ],
      chainId: 5,
      url: process.env.ORIGIN_RPC_URL,
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

