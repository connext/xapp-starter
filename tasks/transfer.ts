import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers } from 'ethers';

export default task("transfer", "Execute a transfer")
  .addParam("originDomain", "The domain ID of the sending chain")
  .addParam("destinationDomain", "The domain ID of the receiving chain")
  .addParam("contractAddress", "The address of the Transfer contract")
  .addParam("tokenAddress", "The address of the TestERC20")
  .addParam("walletPrivateKey", "The private key of the signing wallet")
  .addParam("amount", "The amount to send")
  .setAction(
    async (
      { 
        contractAddress, 
        tokenAddress, 
        originDomain,
        destinationDomain, 
        walletPrivateKey,
        amount
      }
    ) => {
      const contractABI = [
        "event TransferInitiated(address asset, address from, address to)",
        "function transfer(address to, address asset, uint32 originDomain, uint32 destinationDomain, uint256 amount)"
      ];
      
      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]
     
      const provider = new ethers.providers.JsonRpcProvider(process.env.TESTNET_ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(walletPrivateKey, provider);
      const transfer = new ethers.Contract(contractAddress, contractABI, wallet);
      const token = new ethers.Contract(tokenAddress, tokenABI, wallet);

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
          contractAddress,
          amount
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }
                  
      // 3) transfer some tokens 
      async function executeTransfer() {
        let unsignedTx = await transfer.populateTransaction.transfer(
          wallet.address,
          tokenAddress,
          originDomain,
          destinationDomain,
          amount);
        unsignedTx.gasLimit = ethers.BigNumber.from("30000000"); 
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let minted = await mint();
      console.log(minted.status == 1 ? "Successful mint" : "Failed mint");
      let approved = await approve();
      console.log(approved.status == 1 ? "Successful approve" : "Failed approve");
      let transferred = await executeTransfer();
      console.log(transferred.status == 1 ? "Successful transfer" : "Failed transfer"); 
      console.log(`Transaction hash: `, transferred.transactionHash); 
    });
