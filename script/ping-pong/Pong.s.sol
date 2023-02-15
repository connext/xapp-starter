// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {Pong} from "../../src/contract-examples/ping-pong/Pong.sol";

contract DeployPong is Script {
  function run(address connext) external {
    vm.startBroadcast();

    new Pong(connext);

    vm.stopBroadcast();
  }
}
