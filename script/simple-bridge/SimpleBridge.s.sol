// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {SimpleBridge} from "../../src/contract-examples/simple-bridge/SimpleBridge.sol";

contract DeploySimpleBridge is Script {
  function run(address connext) external {
    vm.startBroadcast();

    new SimpleBridge(connext);

    vm.stopBroadcast();
  }
}
