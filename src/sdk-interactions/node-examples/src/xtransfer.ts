import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { create } from "@connext/nxtp-sdk";
import { ethers } from "ethers";
import { signer, nxtpConfig } from "./config.js";

const {nxtpSdkBase} = await create(nxtpConfig);

// Construct the xcall arguments
const callParams = {
  to: await signer.getAddress(), // the address that should receive the funds
  callData: "0x", // empty calldata for a simple transfer
  originDomain: "2221", // send from Kovan
  destinationDomain: "1111", // to Rinkeby
  forceSlow: false,
  receiveLocal: false
};

const xCallArgs = {
  params: callParams,
  transactingAssetId: "0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F", // the Kovan Test Token
  amount: "1000000000000000000", // amount to send (1 TEST)
  relayerFee: "0", // relayers on testnet don't take a fee
};

// Approve the asset transfer because we're sending funds
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
console.log(xcallTxReceipt); // so we can see the transaction hash
const xcallResult = await xcallTxReceipt.wait();
