// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Script.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {ISourceGreeter, SourceGreeter} from "../../src/contract-examples/greeter/SourceGreeter.sol";

contract UpdateGreeting is Script {
  function run(
    address source,
    address token,
    uint256 amount,
    address target, 
    uint32 destinationDomain,
    string memory newGreeting,
    uint256 relayerFee
  ) external {
    ERC20PresetMinterPauser tokenContract = ERC20PresetMinterPauser(token);
    ISourceGreeter sourceContract = ISourceGreeter(source);

    vm.label(source, "Source Greeter");
    vm.label(token, "Token");

    vm.startBroadcast();

    tokenContract.mint(address(this), amount);
    tokenContract.approve(source, amount);

    sourceContract.xUpdateGreeting{value: relayerFee}(
      target,
      destinationDomain, 
      newGreeting, 
      amount,
      relayerFee
    );

    vm.stopBroadcast();
  }
}
