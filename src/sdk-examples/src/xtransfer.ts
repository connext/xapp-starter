import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { create } from "@connext/nxtp-sdk";
import { ethers } from "ethers";
import { signer, nxtpConfig } from "./config.js";

const {nxtpSdkBase} = await create(nxtpConfig);

const signerAddress = await signer.getAddress();

// Address of the TEST token
const asset = nxtpConfig.chains["1735353714"].assets[0].address;

// Send 1 TEST
const amount = "1000000000000000000"; 

// Prepare the xcall params
const xcallParams = {
  origin: "1735353714",    // send from Goerli
  destination: "9991",     // to Mumbai
  to: signerAddress,       // the address that should receive the funds on destination
  asset: asset,            // address of the token contract
  delegate: signerAddress, // address allowed to execute transaction on destination side in addition to relayers
  amount: amount,          // amount of tokens to transfer
  slippage: "30",          // the maximum amount of slippage the user will accept in BPS, 0.3% in this case
  callData: "0x",          // empty calldata for a simple transfer
  relayerFee: "0",         // fee paid to relayers; relayers don't take any fees on testnet
};

// Approve the asset transfer. This is necessary because funds will first be sent to the Connext contract before being bridged.
const approveTxReq = await nxtpSdkBase.approveIfNeeded(
  xcallParams.origin,
  xcallParams.asset,
  xcallParams.amount
)
const approveTxReceipt = await signer.sendTransaction(approveTxReq);
await approveTxReceipt.wait();

// Send the xcall
const xcallTxReq = await nxtpSdkBase.xcall(xcallParams);
xcallTxReq.gasLimit = ethers.BigNumber.from("20000000"); 
const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
console.log(xcallTxReceipt);
const xcallResult = await xcallTxReceipt.wait();
