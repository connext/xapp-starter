// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import "../src/contract-to-contract-interactions/with-calldata/Target.sol";

contract DeployTarget is Script {
  function run(address _source, uint32 _originDomain, address _connext) external {
    vm.startBroadcast();

    IConnextHandler connext = IConnextHandler(_connext);
    new Target(_source, _originDomain, connext);

    vm.stopBroadcast();
  }
}
