// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {DestinationGreeterAuthenticated} from "../../greeter-authenticated/DestinationGreeterAuthenticated.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import "forge-std/Test.sol";

/**
 * @title DestinationGreeterAuthenticatedTestUnit
 *stUni @notice Unit tests for DestinationGreeterAuthenticated.
 */
contract DestinationGreeterAuthenticatedTestUnit is DSTestPlus {
  address private connext = address(1);
  address private source = address(2);
  address private token = address(3);
  DestinationGreeterAuthenticated private target;

  event UpdateCompleted(address sender, uint256 newValue, bool authenticated);

  bytes4 public originSenderSelector = bytes4(keccak256("originSender(bytes)"));
  bytes4 public originSelector = bytes4(keccak256("origin(bytes)"));

  function setUp() public {
    target = new DestinationGreeterAuthenticated(GOERLI_DOMAIN_ID, source, connext);

    vm.label(address(this), "TestContract");
    vm.label(connext, "Connext");
    vm.label(source, "SourceGreeter");
    vm.label(address(target), "DestinationGreeterAuthenticated");
  }

  // function test_xReceive_ShouldUpdateGreeting(bytes32 transferId, uint256 amount, string memory newGreeting) public {
  //   vm.prank(connext);
  //   target.xReceive(transferId, amount, token, source, GOERLI_DOMAIN_ID, abi.encode(newGreeting));
  //   assertEq(target.greeting(), newGreeting);
  // }
}
