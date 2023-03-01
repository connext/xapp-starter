// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {ISimpleBridge} from "../../src/contract-examples/simple-bridge/SimpleBridge.sol";

contract TransferEth is Script {
  function run(
    address source,
    address destinationUnwrapper,
    address weth,
    uint256 amount,
    address recipient,
    uint32 destinationDomain,
    uint256 slippage,
    uint256 relayerFee
  ) external {
    ISimpleBridge sourceContract = ISimpleBridge(source);

    vm.label(source, "Simple Bridge");

    vm.startBroadcast();

    sourceContract.xTransferEth{value: amount + relayerFee}(
      destinationUnwrapper,
      weth,
      amount, 
      recipient, 
      destinationDomain, 
      slippage, 
      relayerFee
    );

    vm.stopBroadcast();
  }
}
