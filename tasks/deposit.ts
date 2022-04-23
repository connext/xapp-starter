import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers } from 'ethers';

export default task("deposit", "Execute a permissionless deposit")
  .addParam("contractAddress", "The address of the XDomainPermissionless contract")
  .addParam("tokenAddress", "The address of the TestERC20")
  .addParam("walletAddress", "The address of the signing wallet")
  .addParam("walletPrivateKey", "The private key of the signing wallet")
  .setAction(
    async (
      { contractAddress, tokenAddress, walletAddress, walletPrivateKey }
    ) => {
      const contractABI = [
        "event DepositInitiated(address asset, uint256 amount, address onBehalfOf)",
        "function deposit(address to, address asset, uint32 originDomain, uint32 destinationDomain, uint256 amount)"
      ];
      
      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]
     
      const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL_KOVAN);
      const wallet = new ethers.Wallet(walletPrivateKey, provider);
      const xPermissionless = new ethers.Contract(contractAddress, contractABI, wallet);
      const token = new ethers.Contract(tokenAddress, tokenABI, wallet);

      const amount = ethers.BigNumber.from("1000000000000000000");

      // 1) mint some tokens 
      async function mint() {
        let unsignedTx = await token.populateTransaction.mint(
          walletAddress,
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
                  
      // 3) execute the permissionless deposit 
      async function deposit() {
        let unsignedTx = await xPermissionless.populateTransaction.deposit(
          walletAddress,
          tokenAddress,
          2221,
          1111,
          amount);
        unsignedTx.gasLimit = ethers.BigNumber.from("30000000"); 
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let minted = await mint();
      console.log(minted.status == 1 ? "Successful mint" : "Failed mint");
      let approved = await approve();
      console.log(approved.status == 1 ? "Successful approve" : "Failed approve");
      let deposited = await deposit();
      console.log(deposited.status == 1 ? "Successful deposit" : "Failed deposit"); 
      console.log(`Transaction hash: `, deposited.transactionHash); 
    });
