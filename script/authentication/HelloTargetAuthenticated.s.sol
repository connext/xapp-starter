// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import "../../src/contract-examples/authentication/HelloTargetAuthenticated.sol";

contract DeployHelloTargetAuthenticated is Script {
  function run(uint32 _originDomain, address sourceContract, address _connext) external {
    vm.startBroadcast();

    IConnext connext = IConnext(_connext);
    new HelloTargetAuthenticated(_originDomain, sourceContract, connext);

    vm.stopBroadcast();
  }
}
