// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {Ping} from "../../src/contract-examples/ping-pong/Ping.sol";

contract DeployPing is Script {
  function run(address _connext) external {
    vm.startBroadcast();

    IConnext connext = IConnext(_connext);
    new Ping(connext);

    vm.stopBroadcast();
  }
}
