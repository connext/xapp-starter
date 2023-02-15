import { task } from "hardhat/config";
import { ethers, BigNumber } from 'ethers';

import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

export default task("transfer", "Execute xTransfer on the Simple Bridge with TEST tokens")
  .setAction(
    async () => {
      const contractABI = [
        "function xTransfer(address token, uint256 amount, address recipient, uint32 destinationDomain, uint256 slippage, uint256 relayerFee) external payable"
      ];
      
      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]

      // Grab input params from .env
      const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const token = new ethers.Contract(process.env.ORIGIN_TOKEN!, tokenABI, wallet);
      const source = new ethers.Contract(process.env.SIMPLE_BRIDGE!, contractABI, wallet);
      const destinationDomain = process.env.DESTINATION_DOMAIN;
      const recipient = process.env.RECIPIENT;
      const amount = BigNumber.from(process.env.AMOUNT);
      const slippage = BigNumber.from(process.env.MAX_SLIPPAGE);
      const relayerFee = BigNumber.from(process.env.RELAYER_FEE);

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
          source.address,
          amount
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }
                  
      // 3) transfer the tokens 
      async function xTransfer() {
        let unsignedTx = await source.populateTransaction.xTransfer(
          token.address,
          amount,
          recipient,
          destinationDomain,
          slippage,
          relayerFee,
          {
            gasLimit: ethers.BigNumber.from("2000000"),
            value: relayerFee
          }
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let minted = await mint();
      console.log(minted.status == 1 ? "Successful mint" : "Failed mint");
      let approved = await approve();
      console.log(approved.status == 1 ? "Successful approve" : "Failed approve");
      let transferred = await xTransfer();
      console.log(transferred.status == 1 ? "Successful transfer" : "Failed transfer"); 
      console.log(`Transaction hash: `, transferred.transactionHash); 
    });
