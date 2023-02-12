// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {Ping} from "../../src/contract-examples/ping-pong/Ping.sol";

contract DeployPing is Script {
  function run(address connext) external {
    vm.startBroadcast();

    new Ping(connext);

    vm.stopBroadcast();
  }
}
