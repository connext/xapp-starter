import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { create } from "@connext/nxtp-sdk";
import { ethers } from "ethers";
import { signer, nxtpConfig } from "./config.js";

const {nxtpSdkBase} = await create(nxtpConfig);

const signerAddress = await signer.getAddress();

const amount = 1000000000000000000; // amount to send (1 TEST)

// Construct the xcall arguments
const callParams = {
  to: signerAddress, // the address that should receive the funds
  callData: "0x", // empty calldata for a simple transfer
  originDomain: "1735353714", // send from Goerli
  destinationDomain: "1735356532", // to Optimism-Goerli
  agent: signerAddress, // address allowed to transaction on destination side in addition to relayers
  recovery: signerAddress,
  forceSlow: false, // option to force Nomad slow path (~30 mins) instead of paying 0.05% fee
  receiveLocal: false, // option to receive the local Nomad-flavored asset instead of the adopted asset
  callback: ethers.constants.AddressZero, // no callback so use the zero address
  callbackFee: "0", // fee paid to relayers for the callback; no fees on testnet
  relayerFee: "0", // fee paid to relayers for the forward call; no fees on testnet
  destinationMinOut: (amount * 0.99).toString(), // accept a 1% slippage tolerance on the destination-side stableswap
};

const xCallArgs = {
  params: callParams,
  transactingAssetId: "0x3FFc03F05D1869f493c7dbf913E636C6280e0ff9", // the Goerli Test Token
  transactingAmount: amount.toString(), 
  originMinOut: (amount * 0.99).toString() // accept a 1% slippage tolerance on the origin-side stableswap
};

// Approve the asset transfer because we're sending funds
const approveTxReq = await nxtpSdkBase.approveIfNeeded(
  xCallArgs.params.originDomain,
  xCallArgs.transactingAssetId,
  xCallArgs.transactingAmount
)
const approveTxReceipt = await signer.sendTransaction(approveTxReq);
await approveTxReceipt.wait();

// Send the xcall
const xcallTxReq = await nxtpSdkBase.xcall(xCallArgs);
xcallTxReq.gasLimit = ethers.BigNumber.from("20000000"); 
const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
console.log(xcallTxReceipt); // so we can see the transaction hash
const xcallResult = await xcallTxReceipt.wait();
