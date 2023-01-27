import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { SdkConfig } from "@connext/sdk";
import { ethers } from "ethers";

// Create a Signer and connect it to a Provider on the sending chain
const privateKey = process.env.PRIVATE_KEY;
let signer = new ethers.Wallet(privateKey);

const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
signer = signer.connect(provider);
const signerAddress = await signer.getAddress();

const sdkConfig: SdkConfig = {
  logLevel: "info",
  signerAddress: signerAddress,
  network: "testnet",
  chains: {
    1735353714: {
      providers: ["https://goerli.infura.io/v3/d2560cac8f5645fba802260cf1f8c777"],
    },
    9991: {
      providers: ["https://polygon-mumbai.infura.io/v3/d2560cac8f5645fba802260cf1f8c777"],
    },
  },
};

export { signer, sdkConfig };
