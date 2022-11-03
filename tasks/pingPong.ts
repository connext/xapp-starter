import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers } from 'ethers';

export default task("pingPong", "Execute sendPing on the Ping contract")
  .addParam("destinationDomain", "The domain ID of the receiving chain")
  .addParam("pingAddress", "The address of the Ping contract")
  .addParam("pongAddress", "The address of the Pong contract")
  .addParam("tokenAddress", "The address of the TestERC20 on the origin domain")
  .addParam("amount", "The amount to send")
  .addOptionalParam("relayerFee", "The fee paid to relayers")
  .setAction(
    async (
      { 
        destinationDomain, 
        pingAddress, 
        pongAddress, 
        tokenAddress,
        amount,
        relayerFee
      }
    ) => {
      const contractABI = [
        "function sendPing(uint32 destinationDomain, address target, address token, uint256 amount, uint256 relayerFee)"
      ];
      
      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]
     
      const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const ping = new ethers.Contract(pingAddress, contractABI, wallet);
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
          pingAddress,
          amount
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }
                  
      // 3) send the ping
      async function executePing() {
        let unsignedTx = await ping.populateTransaction.sendPing(
          destinationDomain,
          pongAddress,
          tokenAddress,
          amount,
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
      let transferred = await executePing();
      console.log(transferred.status == 1 ? "Successful ping" : "Failed ping"); 
      console.log(`Transaction hash: `, transferred.transactionHash); 
    });
