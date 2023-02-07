// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
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
    uint256 slippage,
    uint256 relayerFee
  ) external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    ERC20PresetMinterPauser tokenContract = ERC20PresetMinterPauser(token);
    ISourceGreeter sourceContract = ISourceGreeter(source);

    vm.label(source, "Source Greeter");
    vm.label(token, "Token");

    vm.startBroadcast(deployerPrivateKey);

    tokenContract.mint(address(this), amount);
    tokenContract.approve(source, amount);
    sourceContract.updateGreeting{value: relayerFee}(
      token, 
      target, 
      destinationDomain, 
      newGreeting, 
      slippage, 
      relayerFee
    );

    vm.stopBroadcast();
  }
}
