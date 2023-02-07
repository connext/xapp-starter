// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DestinationGreeterAuthenticated} from "../../src/contract-examples/greeter-authenticated/DestinationGreeterAuthenticated.sol";

contract DeployDestinationGreeterAuthenticated is Script {
  function run(uint32 _originDomain, address _sourceContract, address _connext) external {
    vm.startBroadcast();

    new DestinationGreeterAuthenticated(_originDomain, _sourceContract, _connext);

    vm.stopBroadcast();
  }
}
