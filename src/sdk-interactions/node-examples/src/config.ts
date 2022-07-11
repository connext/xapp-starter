import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { NxtpSdkConfig } from "@connext/nxtp-sdk";
import { ethers } from "ethers";

// Create a Signer and connect it to a Provider on the sending chain
const privateKey = process.env.PRIVATE_KEY;
let signer = new ethers.Wallet(privateKey);

const provider = new ethers.providers.JsonRpcProvider(process.env.RINKEBY_RPC_URL);
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
          symbol: "TEST",
          address: "0x3FFc03F05D1869f493c7dbf913E636C6280e0ff9",
        },
      ],
    },
    "3331": {
      providers: [process.env.GOERLI_RPC_URL],
      assets: [
        {
          name: "TEST",
          symbol: "TEST",
          address: "0x3FFc03F05D1869f493c7dbf913E636C6280e0ff9",
        },
      ],
    },
  },
};

export { signer, nxtpConfig };
