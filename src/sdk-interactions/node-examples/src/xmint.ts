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
  to: "0x3FFc03F05D1869f493c7dbf913E636C6280e0ff9", // Rinkeby Test Token - this is the contract we are targeting
  callData: calldata, 
  originDomain: "1111", // send from Rinkeby
  destinationDomain: "3331", // to Goerli
  agent: signerAddress, // address allowed to execute in addition to relayers 
  recovery: await signer.getAddress(),
  forceSlow: false,
  receiveLocal: false,
  callback: ethers.constants.AddressZero,
  callbackFee: "0",
  relayerFee: "0", // relayers on testnet don't take a fee
  slippageTol: "9995", // tolerate .05% slippage
};

const xCallArgs = {
  params: callParams,
  transactingAssetId: ethers.constants.AddressZero, // not sending funds, so just use address 0
  amount: "0", // not sending funds, so no need for the approval dance
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
