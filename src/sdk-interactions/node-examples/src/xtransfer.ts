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
  agent: signerAddress, // address allowed to execute transaction on destination side in addition to relayers
  recovery: signerAddress, // fallback address to send funds to if execution fails on destination side
  forceSlow: false, // option to force slow path instead of paying 0.05% fee on fast liquidity transfers
  receiveLocal: false, // option to receive the local bridge-flavored asset instead of the adopted asset
  callback: ethers.constants.AddressZero, // zero address because we don't expect a callback
  callbackFee: "0", // fee paid to relayers; relayers don't take any fees on testnet
  relayerFee: "0", // fee paid to relayers; relayers don't take any fees on testnet
  destinationMinOut: (amount * 0.97).toString(), // the minimum amount that the user will accept due to slippage from the StableSwap pool (3% here)
};

const xCallArgs = {
  params: callParams,
  transactingAsset: "0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1", // the Goerli Test Token
  transactingAmount: amount.toString(), 
  originMinOut: (amount * 0.97).toString() // the minimum amount that the user will accept due to slippage from the StableSwap pool (3% here)
};

// Approve the asset transfer because we're sending funds
const approveTxReq = await nxtpSdkBase.approveIfNeeded(
  xCallArgs.params.originDomain,
  xCallArgs.transactingAsset,
  xCallArgs.transactingAmount
)
const approveTxReceipt = await signer.sendTransaction(approveTxReq);
await approveTxReceipt.wait();

// Send the xcall
const xcallTxReq = await nxtpSdkBase.xcall(xCallArgs);
xcallTxReq.gasLimit = ethers.BigNumber.from("20000000"); 
const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
console.log(xcallTxReceipt);
const xcallResult = await xcallTxReceipt.wait();
