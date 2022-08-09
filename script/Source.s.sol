// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import "../src/contract-to-contract-interactions/with-calldata/Source.sol";

contract DeploySource is Script {
  function run(address _connext, address _promiseRouter) external {
    vm.startBroadcast();

    IConnextHandler connext = IConnextHandler(_connext);
    new Source(connext, _promiseRouter);

    vm.stopBroadcast();
  }
}
