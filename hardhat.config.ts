
import { HardhatUserConfig } from "hardhat/types";
import { config as dotenvConfig } from "dotenv";

import "./tasks/transfer";
import "./tasks/deposit";
import "./tasks/update";

dotenvConfig();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.11",
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {}
  },
  paths: {
    sources: "./src",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};

export default config;

