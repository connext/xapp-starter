// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {SourceGreeterAuthenticated} from "../../src/contract-examples/greeter-authenticated/SourceGreeterAuthenticated.sol";

contract DeploySourceGreeterAuthenticated is Script {
  function run(address _connext) external {
    vm.startBroadcast();

    IConnext connext = IConnext(_connext);
    new SourceGreeterAuthenticated(connext);

    vm.stopBroadcast();
  }
}
