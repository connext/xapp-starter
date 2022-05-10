import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { create, NxtpSdkConfig } from "@connext/nxtp-sdk";
import { ethers } from "ethers";

// Create a Signer and connect it to a Provider on the sending chain
const privateKey = process.env.PRIVATE_KEY;
let signer = new ethers.Wallet(privateKey);

const provider = new ethers.providers.JsonRpcProvider(process.env.KOVAN_RPC_URL);
signer = signer.connect(provider);
const signerAddress = await signer.getAddress();

// Replace the placeholder provider URLs
const nxtpConfig: NxtpSdkConfig = {
  logLevel: "info",
  signerAddress: signerAddress,
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

const {nxtpSdkBase} = await create(nxtpConfig);

const callParams = {
  to: signerAddress, // the address that should receive the funds
  callData: "0x", // empty calldata for a simple transfer
  originDomain: "2221", // send from Kovan
  destinationDomain: "1111", // to Rinkeby
};

const xCallArgs = {
  params: callParams,
  transactingAssetId: "0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F", // the Kovan Test Token
  amount: "1000000000000000000", // amount to send (1 TEST)
  relayerFee: "0", // relayers on testnet don't take a fee
};

// Approve the asset transfer
const approveTxReq = await nxtpSdkBase.approveIfNeeded(
  xCallArgs.params.originDomain,
  xCallArgs.transactingAssetId,
  xCallArgs.amount
)
const approveTxReceipt = await signer.sendTransaction(approveTxReq);
const approveResult = await approveTxReceipt.wait();

// Send the xcall
const xcallTxReq = await nxtpSdkBase.xcall(xCallArgs);
xcallTxReq.gasLimit = ethers.BigNumber.from("30000000"); 
const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
console.log(xcallTxReceipt); // so you can see the transaction hash
const xcallResult = await xcallTxReceipt.wait();
