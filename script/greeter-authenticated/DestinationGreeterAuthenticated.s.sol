// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {DestinationGreeterAuthenticated} from "../../src/contract-examples/greeter-authenticated/DestinationGreeterAuthenticated.sol";

contract DeployDestinationGreeterAuthenticated is Script {
  function run(uint32 originDomain, address sourceContract, address connext) external {
    vm.startBroadcast();

    new DestinationGreeterAuthenticated(originDomain, sourceContract, connext);

    vm.stopBroadcast();
  }
}
