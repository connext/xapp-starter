// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {HelloSource} from "../../hello-quickstart/HelloSource.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

/**
 * @title HelloSourceTestForked
 * @notice Integration tests for HelloSource. Should be run with forked testnet (Goerli).
 */
contract HelloSourceTestForked is DSTestPlus {
  // Addresses on Goerli
  IConnext public connext = IConnext(0x99A784d082476E551E5fc918ce3d849f2b8e89B6);
  ERC20PresetMinterPauser public token = ERC20PresetMinterPauser(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);

  HelloSource private source;
  address private target = address(1);
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    source = new HelloSource(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(source), "HelloSource");
    vm.label(target, "HelloTarget");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_updateGreetingShouldWork(string memory newGreeting) public {
    vm.startPrank(userChainA);

    uint256 cost = source.cost();

    // Mint userChainA some TEST
    token.mint(userChainA, cost);

    // Approve the amount to HelloSource
    token.approve(address(source), cost);

    // Test that xcall is called
    vm.expectCall(
      address(connext), 
      abi.encodeCall(
        IConnext.xcall, 
        (
          POLYGON_MUMBAI_DOMAIN_ID,
          target,
          address(token),
          userChainA,
          cost,
          30,
          abi.encode(newGreeting)
        )
      )
    );

    source.updateGreeting(
      target,
      POLYGON_MUMBAI_DOMAIN_ID,
      newGreeting,
      0
    );
    vm.stopPrank();
  }
}
