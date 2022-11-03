import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers, BigNumber } from 'ethers';

export default task("hello", "Execute updateGreeting on Hello")
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

      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]
     
      const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const source = new ethers.Contract(sourceAddress, contractABI, wallet);
      const TEST_ERC20 = "0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1";
      const amount = BigNumber.from("1000500300000000000");
      const token = new ethers.Contract(TEST_ERC20, tokenABI, wallet);

      // 1) mint some tokens 
      async function mint() {
        let unsignedTx = await token.populateTransaction.mint(
          wallet.address,
          amount
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      // 2) approve the token transfer
      async function approve() {
        let unsignedTx = await token.populateTransaction.approve(
          sourceAddress,
          amount
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      // 3) update the greeting
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

      let minted = await mint();
      console.log(minted.status == 1 ? "Successful mint" : "Failed mint");
      let approved = await approve();
      console.log(approved.status == 1 ? "Successful approve" : "Failed approve");
      let updated = await updateGreeting();
      console.log(updated.status == 1 ? "Successful update" : "Failed update"); 
      console.log(`Transaction hash: `, updated.transactionHash); 
    });
