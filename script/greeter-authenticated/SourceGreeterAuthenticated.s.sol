// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {SourceGreeterAuthenticated} from "../../src/contract-examples/greeter-authenticated/SourceGreeterAuthenticated.sol";

contract DeploySourceGreeterAuthenticated is Script {
  function run(address connext) external {
    vm.startBroadcast();

    new SourceGreeterAuthenticated(connext);

    vm.stopBroadcast();
  }
}
