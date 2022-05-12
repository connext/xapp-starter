import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { NxtpSdkConfig } from "@connext/nxtp-sdk";
import { ethers } from "ethers";

// Create a Signer and connect it to a Provider on the sending chain
const privateKey = process.env.PRIVATE_KEY;
let signer = new ethers.Wallet(privateKey);

const provider = new ethers.providers.JsonRpcProvider(process.env.KOVAN_RPC_URL);
signer = signer.connect(provider);

const nxtpConfig: NxtpSdkConfig = {
  logLevel: "info",
  signerAddress: await signer.getAddress(),
  chains: {
    "1111": {
      providers: [process.env.RINKEBY_RPC_URL],
      assets: [
        {
          name: "TEST",
          address: "0xB7b1d3cC52E658922b2aF00c5729001ceA98142C",
        },
      ],
    },
    "2221": {
      providers: [process.env.KOVAN_RPC_URL],
      assets: [
        {
          name: "TEST",
          address: "0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F",
        },
      ],
    },
  },
};

export { signer, nxtpConfig };
