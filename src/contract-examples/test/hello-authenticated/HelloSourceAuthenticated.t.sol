// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {HelloSourceAuthenticated} from "../../hello-authenticated/HelloSourceAuthenticated.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";

/**
 * @title HelloSourceAuthenticatedTestForked
 * @notice Integration tests for HelloSourceAuthenticated. Should be run with forked testnet (Goerli).
 */
contract HelloSourceAuthenticatedTestForked is DSTestPlus {
  // Addresses on Goerli
  IConnext public connext = IConnext(0x99A784d082476E551E5fc918ce3d849f2b8e89B6);

  HelloSourceAuthenticated private source;
  address private target = address(1);
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    source = new HelloSourceAuthenticated(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(source), "HelloSourceAuthenticated");
    vm.label(target, "HelloTargetAuthenticated");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_HelloSourceAuthenticated_updateGreetingShouldWork(string memory newGreeting) public {
    vm.startPrank(userChainA);

    // Test that xcall is called
    vm.expectCall(
      address(connext), 
      abi.encodeCall(
        IConnext.xcall, 
        (
          POLYGON_MUMBAI_DOMAIN_ID,
          target,
          address(0),
          userChainA,
          0,
          0,
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
