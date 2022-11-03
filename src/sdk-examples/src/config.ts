import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { NxtpSdkConfig } from "@connext/nxtp-sdk";
import { ethers } from "ethers";

// Create a Signer and connect it to a Provider on the sending chain
const privateKey = process.env.PRIVATE_KEY;
let signer = new ethers.Wallet(privateKey);

const provider = new ethers.providers.JsonRpcProvider(process.env.GOERLI_RPC_URL);
signer = signer.connect(provider);
const signerAddress = await signer.getAddress();

const nxtpConfig: NxtpSdkConfig = {
  logLevel: "info",
  signerAddress: signerAddress,
  chains: {
    // Goerli
    "1735353714": {
      providers: [process.env.GOERLI_RPC_URL],
      assets: [
        {
          name: "TEST",
          symbol: "TEST",
          address: "0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1",
        },
      ],
    },
    // Optimism-Goerli
    "1735356532": {
      providers: [process.env.OPTIMISM_GOERLI_RPC_URL],
      assets: [
        {
          name: "TEST",
          symbol: "TEST",
          address: "0x68Db1c8d85C09d546097C65ec7DCBFF4D6497CbF",
        },
      ],
    },
    // Polygon-Mumbai
    "9991": {
      providers: [process.env.MUMBAI_RPC_URL],
      assets: [
        {
          name: "TEST",
          symbol: "TEST",
          address: "0xeDb95D8037f769B72AAab41deeC92903A98C9E16",
        },
      ],
    },
  },
};

export { signer, nxtpConfig };
