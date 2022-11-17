// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {HelloTarget} from "../../hello-quickstart/HelloTarget.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import "forge-std/Test.sol";

/**
 * @title HelloTargetTestUnit
 *stUni @notice Unit tests for HelloTarget.
 */
contract HelloTargetTestUnit is DSTestPlus {
  address private connext = address(1);
  address private source = address(2);
  address private token = address(0xeDb95D8037f769B72AAab41deeC92903A98C9E16);
  HelloTarget private target;

  function setUp() public {
    target = new HelloTarget();

    vm.label(address(this), "TestContract");
    vm.label(connext, "Connext");
    vm.label(source, "HelloSource");
    vm.label(address(target), "HelloTarget");
  }

  function test_xReceive_ShouldUpdateGreeting(bytes32 transferId, uint256 amount, uint32 domain, string memory newGreeting) public {
    vm.assume(amount >= target.cost());
    target.xReceive(transferId, amount, token, address(this), domain, abi.encode(newGreeting));
    assertEq(target.greeting(), newGreeting);
  }
}
