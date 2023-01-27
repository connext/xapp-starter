import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { create } from "@connext/sdk";
import { ethers } from "ethers";
import { signer, sdkConfig } from "./config.js";

const {sdkBase} = await create(sdkConfig);

const signerAddress = await signer.getAddress();

// Goerli domain ID
const originDomain = "1735353714";

// Mumbai domain ID
const destinationDomain = "9991";

// Address of the TEST token on Goerli
const asset = "0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1";

// Send 1 TEST
const amount = "1000000000000000000"; 

// Estimate the relayer fee
const relayerFee = (await sdkBase.estimateRelayerFee({originDomain, destinationDomain})).toString();

// Prepare the xcall params
const xcallParams = {
  origin: originDomain,    // send from Goerli
  destination: destinationDomain,     // to Mumbai
  to: signerAddress,       // the address that should receive the funds on destination
  asset: asset,            // address of the token contract
  delegate: signerAddress, // address allowed to execute transaction on destination side in addition to relayers
  amount: amount,          // amount of tokens to transfer
  slippage: "30",          // the maximum amount of slippage the user will accept in BPS, 0.3% in this case
  callData: "0x",          // empty calldata for a simple transfer (byte-encoded)
  relayerFee: relayerFee,  // fee paid to relayers 
};

// Approve the asset transfer. This is necessary because funds will first be sent to the Connext contract before being bridged.
const approveTxReq = await sdkBase.approveIfNeeded(
  xcallParams.origin,
  xcallParams.asset,
  xcallParams.amount
)
const approveTxReceipt = await signer.sendTransaction(approveTxReq);
await approveTxReceipt.wait();

// Send the xcall
const xcallTxReq = await sdkBase.xcall(xcallParams);
xcallTxReq.gasLimit = ethers.BigNumber.from("20000000"); 
const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
console.log(xcallTxReceipt);
const xcallResult = await xcallTxReceipt.wait();
