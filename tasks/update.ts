import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers } from 'ethers';

export default task("update", "Execute an authenticated update")
  .addParam("originDomain", "The domain ID of the sending chain")
  .addParam("destinationDomain", "The domain ID of the receiving chain")
  .addParam("sourceAddress", "The address of the Source contract")
  .addParam("targetAddress", "The address of the Target contract")
  .addParam("tokenAddress", "The address of the TestERC20")
  .addParam("walletPrivateKey", "The private key of the signing wallet")
  .addOptionalParam("value", "The new value to update to")
  .addOptionalParam("authenticated", "True if this is an authenticated update")
  .setAction(
    async (
      { 
        sourceAddress, 
        targetAddress, 
        tokenAddress, 
        originDomain, 
        destinationDomain, 
        walletPrivateKey,
        value: _value,
        authenticated: _authenticated
      }
    ) => {
      const contractABI = [
        "event UpdateInitiated(address asset, uint256 amount, address onBehalfOf)",
        "function updateValue(address to, address asset, uint32 originDomain, uint32 destinationDomain, uint256 amount, bool authenticated)"
      ];
     
      const value = _value || 1;
      const authenticated = _authenticated || false;
      
      const provider = new ethers.providers.JsonRpcProvider(process.env.TESTNET_ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(walletPrivateKey, provider);
      const source = new ethers.Contract(sourceAddress, contractABI, wallet);

      async function updateValue() {
        let unsignedTx = await source.populateTransaction.updateValue(
          targetAddress,
          tokenAddress,
          originDomain,
          destinationDomain,
          value,
          authenticated === "true");
        unsignedTx.gasLimit = ethers.BigNumber.from("20000000"); 
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let updated = await updateValue();
      console.log(updated.status == 1 ? "Successful update" : "Failed update"); 
      console.log(`Transaction hash: `, updated.transactionHash); 
    });
