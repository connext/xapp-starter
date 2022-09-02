import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { create, NxtpSdkConfig } from "@connext/nxtp-sdk";
import { ethers } from "ethers";
import { signer, nxtpConfig } from "./config.js";

const {nxtpSdkBase} = await create(nxtpConfig);

const signerAddress = await signer.getAddress();

// Create and encode the calldata
const contractABI = [
  "function mint(address account, uint256 amount)"
];
const iface = new ethers.utils.Interface(contractABI);

const calldata = iface.encodeFunctionData(
  "mint", 
  [
    await signer.getAddress(), // the address that should receive the minted funds
    ethers.BigNumber.from("100000000000000000000") // amount to mint (100 TEST)
  ]
)

// Construct the xcall arguments
const callParams = {
  to: "0x68Db1c8d85C09d546097C65ec7DCBFF4D6497CbF", // Opt-Goerli Test Token contract - the target
  callData: calldata, 
  originDomain: "1735353714", // send from Goerli
  destinationDomain: "1735356532", // to Optimism-Goerli
  agent: signerAddress, // address allowed to transaction on destination side in addition to relayers
  recovery: await signer.getAddress(), // fallback address to send funds to if execution fails on destination side
  forceSlow: false, // option to force Nomad slow path (~30 mins) instead of paying 0.05% fee
  receiveLocal: false, // option to receive the local Nomad-flavored asset instead of the adopted asset
  callback: ethers.constants.AddressZero, // no callback so use the zero address
  callbackFee: "0", // fee paid to relayers for the callback; no fees on testnet
  relayerFee: "0", // fee paid to relayers for the forward call; no fees on testnet
  destinationMinOut: "0", // not sending funds so minimum can be 0
};

const xCallArgs = {
  params: callParams,
  transactingAsset: ethers.constants.AddressZero, // not sending funds so just use address 0
  transactingAmount: "0", // not sending funds with this calldata-only xcall
  originMinOut: "0" // not sending funds so minimum can be 0
};

// Send the xcall
const xcallTxReq = await nxtpSdkBase.xcall(xCallArgs);
xcallTxReq.gasLimit = ethers.BigNumber.from("20000000"); 
const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
console.log(xcallTxReceipt);
const xcallResult = await xcallTxReceipt.wait();
