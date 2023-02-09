// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {SourceGreeter} from "../../src/contract-examples/greeter/SourceGreeter.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeploySourceGreeter is Script {
  function run(address _connext, address _token) external {
    vm.startBroadcast();

    IConnext connext = IConnext(_connext);
    IERC20 token = IERC20(_token);
    new SourceGreeter(connext, token);

    vm.stopBroadcast();
  }
}
