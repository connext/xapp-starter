// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
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
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    ISourceGreeterAuthenticated sourceContract = ISourceGreeterAuthenticated(source);

    vm.label(source, "Source Greeter");

    vm.startBroadcast(deployerPrivateKey);

    sourceContract.updateGreeting{value: relayerFee}(target, destinationDomain, newGreeting, relayerFee);

    vm.stopBroadcast();
  }
}
