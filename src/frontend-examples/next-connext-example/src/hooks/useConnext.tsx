import { useState, useEffect } from "react";
import { useAccount, useSigner } from "wagmi";
import { create, SdkConfig } from "@connext/sdk";
import { BigNumber } from "ethers";

const useConnext = () => {
  const { address } = useAccount();
  const { data: signer } = useSigner();
  const [bridging, setStartBridging] = useState<boolean>(false);
  const [tracker, setTracker] = useState<string | null>(null);

  const handleBridgeState = (): void => {
    setStartBridging(true);
  };

  const sdkConfig: SdkConfig = {
    signerAddress: address,
    // Use `mainnet` when you're ready...
    network: "testnet",
    // Add more chains here! Use mainnet domains if `network: mainnet`.
    // This information can be found at https://docs.connext.network/resources/supported-chains
    chains: {
      1735353714: {
        // Goerli domain ID
        providers: ["https://rpc.ankr.com/eth_goerli"],
      },
      1735356532: {
        // Optimism-Goerli domain ID
        providers: ["https://goerli.optimism.io"],
      },
    },
  };

  useEffect(() => {
    console.log(bridging, "console from hooks");
    if (!bridging) {
      return;
    }
    const handlingXCalls = async () => {
      if (!signer) {
        console.log(" No signer available");
        return;
      }
      const { sdkBase } = (await create(sdkConfig)) || {};
      // xcall params
      const originDomain = "1735353714";
      const destinationDomain = "1735356532";
      const originAsset = "0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1"; // Test asset
      const amount = "10";
      const slippage = "10000";
      const relayerFee = await sdkBase.estimateRelayerFee({
        originDomain,
        destinationDomain,
      });

      console.log(relayerFee.toString(), "relayer fees");

      //   Prepare the xcall params
      const xcallParams = {
        origin: originDomain, // send from Goerli
        destination: destinationDomain, // to Mumbai
        to: address as string, // the address that should receive the funds on destination
        asset: originAsset, // address of the token contract
        delegate: address, // address allowed to execute transaction on destination side in addition to relayers
        amount: amount, // amount of tokens to transfer
        slippage: slippage, // the maximum amount of slippage the user will accept in BPS (e.g. 30 = 0.3%)
        callData: "0x", // empty calldata for a simple transfer (byte-encoded)
        relayerFee: relayerFee.toString(), // fee paid to relayers
      };

      // Approve the asset transfer if the current allowance is lower than the amount.
      // Necessary because funds will first be sent to the Connext contract in xcall.
      const approveTxReq = await sdkBase.approveIfNeeded(
        originDomain,
        originAsset,
        amount
      );
      console.log(approveTxReq, "approve tx request");
      if (approveTxReq) {
        const approveTxReceipt = await signer.sendTransaction(approveTxReq);
        await approveTxReceipt.wait();
      }

      // Send the xcall
      const xcallTxReq = await sdkBase.xcall(xcallParams);
      xcallTxReq.gasLimit = BigNumber.from("20000000");
      const xcallTxReceipt = await signer.sendTransaction(xcallTxReq);
      console.log(xcallTxReceipt);
      const { hash } = xcallTxReceipt || null;
      if (hash) {
        setTracker(`https://testnet.connextscan.io/tx/${hash}?src=search`);
      }
      await xcallTxReceipt.wait();
    };

    handlingXCalls();
  }, [bridging]);
  return { tracker, handleBridgeState };
};

export default useConnext;
