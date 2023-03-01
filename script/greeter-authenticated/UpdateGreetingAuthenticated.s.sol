// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {
  ISourceGreeterAuthenticated,
  SourceGreeterAuthenticated
} from "../../src/contract-examples/greeter-authenticated/SourceGreeterAuthenticated.sol";

contract UpdateGreetingAuthenticated is Script {
  function run(
    address source,
    address target, 
    uint32 destinationDomain,
    string memory newGreeting,
    uint256 relayerFee
  ) external {
    ISourceGreeterAuthenticated sourceContract = ISourceGreeterAuthenticated(source);

    vm.label(source, "Source Greeter");

    vm.startBroadcast();

    sourceContract.xUpdateGreeting{value: relayerFee}(target, destinationDomain, newGreeting, relayerFee);

    vm.stopBroadcast();
  }
}
