import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers, BigNumber } from 'ethers';

export default task("update-greeting-auth", "Execute updateGreetingAuthenticated on SourceGreeterAuthenticated")
  .setAction(
    async () => {
      const contractABI = [
        "function xUpdateGreeting(address target, uint32 destinationDomain, string newGreeting, uint256 relayerFee) external payable"
      ];

      const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const source = new ethers.Contract(process.env.SOURCE_GREETER_AUTHENTICATED!, contractABI, wallet);
      const targetAddress = process.env.DESTINATION_GREETER;
      const destinationDomain = process.env.DESTINATION_DOMAIN;
      const relayerFee = BigNumber.from(process.env.RELAYER_FEE);
      const newGreeting = process.env.NEW_GREETING_AUTHENTICATED;

      async function xUpdateGreeting() {
        let unsignedTx = await source.populateTransaction.xUpdateGreeting(
          targetAddress,
          destinationDomain,
          newGreeting,
          relayerFee,
          {
            gasLimit: ethers.BigNumber.from("2000000"),
            value: relayerFee
          }
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let updated = await xUpdateGreeting();
      console.log(updated.status == 1 ? "Successful update" : "Failed update"); 
      console.log(`Transaction hash: `, updated.transactionHash); 
    });
