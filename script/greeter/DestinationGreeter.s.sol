// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {DestinationGreeter} from "../../src/contract-examples/greeter/DestinationGreeter.sol";

contract DeployDestinationGreeter is Script {
  function run(address _token) external {
    vm.startBroadcast();

    new DestinationGreeter(_token);

    vm.stopBroadcast();
  }
}
