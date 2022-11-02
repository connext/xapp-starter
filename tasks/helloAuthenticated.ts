import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers, BigNumber } from 'ethers';

export default task("helloAuthenticated", "Execute updateGreeting on HelloAuthenticated")
  .addParam("destinationDomain", "The domain ID of the receiving chain")
  .addParam("sourceAddress", "The address of the Source contract")
  .addParam("targetAddress", "The address of the Target contract")
  .addParam("greeting", "The new greeting to update to")
  .addOptionalParam("relayerFee", "The fee paid to relayers")
  .setAction(
    async (
      { 
        sourceAddress, 
        targetAddress, 
        originDomain, 
        destinationDomain, 
        greeting,
        relayerFee
      }
    ) => {
      const contractABI = [
        "function updateGreeting(address target, uint32 destinationDomain, string newGreeting, uint256 relayerFee)"
      ];

      const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const source = new ethers.Contract(sourceAddress, contractABI, wallet);

      async function updateGreeting() {
        let unsignedTx = await source.populateTransaction.updateGreeting(
          targetAddress,
          destinationDomain,
          greeting,
          relayerFee ?? 0
        );
        unsignedTx.gasLimit = ethers.BigNumber.from("2000000"); 
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let updated = await updateGreeting();
      console.log(updated.status == 1 ? "Successful update" : "Failed update"); 
      console.log(`Transaction hash: `, updated.transactionHash); 
    });
