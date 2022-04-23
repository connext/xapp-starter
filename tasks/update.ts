import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers } from 'ethers';

export default task("update", "Execute a permissioned update")
  .addParam("contractAddress", "The address of the XDomainPermissioned contract")
  .addParam("middlewareAddress", "The address of the Middleware contract")
  .addParam("tokenAddress", "The address of the TestERC20")
  .addParam("walletAddress", "The address of the signing wallet")
  .addParam("walletPrivateKey", "The private key of the signing wallet")
  .setAction(
    async (
      { contractAddress, middlewareAddress, tokenAddress, walletAddress, walletPrivateKey }
    ) => {
      const contractABI = [
        "event UpdateInitiated(address asset, uint256 amount, address onBehalfOf)",
        "function update(address to, address asset, uint32 originDomain, uint32 destinationDomain, uint256 amount)"
      ];
      
      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]
     
      const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL_KOVAN);
      const wallet = new ethers.Wallet(walletPrivateKey, provider);
      const xPermissioned = new ethers.Contract(contractAddress, contractABI, wallet);
      const middleware = new ethers.Contract(middlewareAddress, contractABI, wallet);
      const token = new ethers.Contract(tokenAddress, tokenABI, wallet);

      const value = 100;

      // 1) execute the permissioned update 
      async function update() {
        let unsignedTx = await xPermissioned.populateTransaction.update(
          walletAddress,
          tokenAddress,
          2221,
          1111,
          value);
        unsignedTx.gasLimit = ethers.BigNumber.from("30000000"); 
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let updated = await update();
      console.log(updated.status == 1 ? "Successful update" : "Failed update"); 
      console.log(`Trasaction hash: `, updated.transactionHash); 
    });
