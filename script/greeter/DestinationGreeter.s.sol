// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {DestinationGreeter} from "../../src/contract-examples/greeter/DestinationGreeter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployDestinationGreeter is Script {
  function run(address _token) external {
    vm.startBroadcast();

    new DestinationGreeter(IERC20(_token));

    vm.stopBroadcast();
  }
}
