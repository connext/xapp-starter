import dotenv from "dotenv";
import dotenvExpand from 'dotenv-expand';
const envConfig = dotenv.config();
dotenvExpand.expand(envConfig);

import { SdkConfig } from "@connext/sdk";
import { ethers } from "ethers";

// Create a Signer and connect it to a Provider on the sending chain
const privateKey = process.env.PRIVATE_KEY;
if (!privateKey) {
  throw Error("Must have private key defined in .env");
}

let signer = new ethers.Wallet(privateKey);

const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
signer = signer.connect(provider);
const signerAddress = await signer.getAddress();

const sdkConfig: SdkConfig = {
  signerAddress: signerAddress,
  // Use `mainnet` when you're ready...
  network: "testnet",
  // Add more chains here! Use mainnet domains if `network: mainnet`
  // This information can be found at https://docs.connext.network/resources/supported-chains
  chains: {
    1735353714: {
      providers: [process.env.GOERLI_RPC_URL!],
    },
    1735356532: {
      providers: [process.env.OPTIMISM_GOERLI_RPC_URL!],
    },
  },
};

export { signer, sdkConfig };
