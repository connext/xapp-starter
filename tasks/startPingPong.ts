import { task } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { ethers, BigNumber } from 'ethers';

export default task("start-ping-pong", "Execute startPingPong on the Ping contract")
  .setAction(
    async () => {
      const contractABI = [
        "function startPingPong(address target, uint32 destinationDomain, uint256 relayerFee) external payable"
      ];
      
      const tokenABI = [
        "function mint(address account, uint256 amount)",
        "function approve(address spender, uint256 amount)"
      ]
     
      const provider = new ethers.providers.JsonRpcProvider(process.env.ORIGIN_RPC_URL);
      const wallet = new ethers.Wallet(String(process.env.PRIVATE_KEY), provider);
      const source = new ethers.Contract(process.env.PING!, contractABI, wallet);
      const targetAddress = process.env.PONG;
      const destinationDomain = process.env.DESTINATION_DOMAIN;
      const relayerFee = BigNumber.from(process.env.RELAYER_FEE);

      // 3) start ping pong
      async function startPingPong() {
        let unsignedTx = await source.populateTransaction.startPingPong(
          targetAddress,
          destinationDomain,
          relayerFee,
          {
            gasLimit: ethers.BigNumber.from("2000000"),
            value: relayerFee
          }
        );
        let txResponse = await wallet.sendTransaction(unsignedTx);
        return await txResponse.wait();
      }

      let transferred = await startPingPong();
      console.log(transferred.status == 1 ? "Successful start ping pong" : "Failed start ping pong"); 
      console.log(`Transaction hash: `, transferred.transactionHash); 
    });
