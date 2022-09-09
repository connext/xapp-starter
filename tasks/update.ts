import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers } from 'ethers';

export default task("update", "Execute an authenticated update")
  .addParam("originDomain", "The domain ID of the sending chain")
  .addParam("destinationDomain", "The domain ID of the receiving chain")
  .addParam("sourceAddress", "The address of the Source contract")
  .addParam("targetAddress", "The address of the Target contract")
  .addOptionalParam("value", "The new value to update to")
  .addOptionalParam("authenticated", "True if this is an authenticated update")
  .setAction(
    async (
      { 
        sourceAddress, 
        targetAddress, 
        originDomain, 
        destinationDomain, 
        value: _value,
        authenticated: _authenticated
      }
    ) => {
      const contractABI = [
        "event UpdateInitiated(address to, uint256 amount, address onBehalfOf)",
        "function xChainUpdate(address to, uint32 originDomain, uint32 destinationDomain, uint256 newValue, bool authenticated)"
      ];
     
      const value = _value || 1;
      const authenticated = _authenticated || false;
      
      const provider = new ethers.providers.JsonRpcProvider(process.env.TESTNET_ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const source = new ethers.Contract(sourceAddress, contractABI, wallet);

      async function xChainUpdate() {
        let unsignedTx = await source.populateTransaction.xChainUpdate(
          targetAddress,
          originDomain,
          destinationDomain,
          value,
          authenticated === "true");
        unsignedTx.gasLimit = ethers.BigNumber.from("2000000"); 
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let updated = await xChainUpdate();
      console.log(updated.status == 1 ? "Successful update" : "Failed update"); 
      console.log(`Transaction hash: `, updated.transactionHash); 
    });
