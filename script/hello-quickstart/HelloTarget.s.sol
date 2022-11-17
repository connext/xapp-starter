// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {HelloTarget} from "../../src/contract-examples/hello-quickstart/HelloTarget.sol";

contract DeployHelloTarget is Script {
  function run() external {
    vm.startBroadcast();

    new HelloTarget();

    vm.stopBroadcast();
  }
}
