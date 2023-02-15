import dotenv from "dotenv";
import dotenvExpand from 'dotenv-expand';
const envConfig = dotenv.config();
dotenvExpand.expand(envConfig);

import { create } from "@connext/sdk";
import { BigNumber } from "ethers";
import { signer, sdkConfig } from "./config.js";

const {sdkBase} = await create(sdkConfig);

const signerAddress = await signer.getAddress();

// Default to Goerli -> Optimism-Goerli with 1 TEST if variables
// are not defined in .env.
const originDomain = process.env.ORIGIN_DOMAIN || "1735353714";
const destinationDomain = process.env.DESTINATION_DOMAIN || "1735356532";
const originAsset = process.env.ORIGIN_TOKEN || "0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1";
const amount = process.env.AMOUNT || "1000000000000000000";
const slippage = process.env.SLIPPAGE || "10000";

// Estimate the relayer fee
const relayerFee = (
  await sdkBase.estimateRelayerFee({
    originDomain, 
    destinationDomain
  })
).toString();

// Prepare the xcall params
const xcallParams = {
  origin: originDomain,           // send from Goerli
  destination: destinationDomain, // to Mumbai
  to: signerAddress,              // the address that should receive the funds on destination
  asset: originAsset,             // address of the token contract
  delegate: signerAddress,        // address allowed to execute transaction on destination side in addition to relayers
  amount: amount,                 // amount of tokens to transfer
  slippage: slippage,             // the maximum amount of slippage the user will accept in BPS (e.g. 30 = 0.3%)
  callData: "0x",                 // empty calldata for a simple transfer (byte-encoded)
  relayerFee: relayerFee,         // fee paid to relayers 
};

// Approve the asset transfer if the current allowance is lower than the amount.
// Necessary because funds will first be sent to the Connext contract in xcall.
const approveTxReq = await sdkBase.approveIfNeeded(
  originDomain,
  originAsset,
  amount
)

if (approveTxReq) {
  const approveTxReceipt = await signer.sendTransaction(approveTxReq);
  await approveTxReceipt.wait();
}

// Send the xcall
const xcallTxReq = await sdkBase.xcall(xcallParams);
xcallTxReq.gasLimit = BigNumber.from("20000000"); 
const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
console.log(xcallTxReceipt);
await xcallTxReceipt.wait();
