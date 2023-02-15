import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers, BigNumber } from 'ethers';

export default task("update-greeting", "Execute xUpdateGreeting on SourceGreeter")
  .setAction(
    async () => {
      const contractABI = [
        "function xUpdateGreeting(address target, uint32 destinationDomain, string newGreeting, uint256 amount, uint256 relayerFee) external payable"
      ];

      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]
     
      const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const source = new ethers.Contract(process.env.SOURCE_GREETER!, contractABI, wallet);
      const targetAddress = process.env.DESTINATION_GREETER;
      const token = new ethers.Contract(process.env.ORIGIN_TOKEN!, tokenABI, wallet);
      const destinationDomain = process.env.DESTINATION_DOMAIN;
      const amount = BigNumber.from(process.env.AMOUNT);
      const relayerFee = BigNumber.from(process.env.RELAYER_FEE);
      const newGreeting = process.env.NEW_GREETING;

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

      // 3) update the greeting
      async function xUpdateGreeting() {
        let unsignedTx = await source.populateTransaction.xUpdateGreeting(
          targetAddress,
          destinationDomain,
          newGreeting,
          amount,
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
      let updated = await xUpdateGreeting();
      console.log(updated.status == 1 ? "Successful update" : "Failed update"); 
      console.log(`Transaction hash: `, updated.transactionHash); 
    });
