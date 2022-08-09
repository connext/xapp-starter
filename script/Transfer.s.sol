// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import "../src/contract-to-contract-interactions/transfer/Transfer.sol";

contract DeployTransfer is Script {
  function run(address _connext) external {
    vm.startBroadcast();

    IConnextHandler connext = IConnextHandler(_connext);
    new Transfer(connext);

    vm.stopBroadcast();
  }
}
