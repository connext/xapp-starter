// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {IPing, Ping} from "../../src/contract-examples/ping-pong/Ping.sol";

contract StartPingPong is Script {
  function run(
    address source,
    address target, 
    uint32 destinationDomain,
    uint256 relayerFee
  ) external {
    IPing sourceContract = IPing(source);

    vm.label(source, "Ping");

    vm.startBroadcast();

    sourceContract.startPingPong{value: relayerFee}(
      target, 
      destinationDomain, 
      relayerFee
    );

    vm.stopBroadcast();
  }
}
