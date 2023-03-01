// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {DestinationGreeterAuthenticated} from "../../greeter-authenticated/DestinationGreeterAuthenticated.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {TestHelper} from "../utils/TestHelper.sol";

/**
 * @title DestinationGreeterAuthenticatedTestUnit
 *stUni @notice Unit tests for DestinationGreeterAuthenticated.
 */
contract DestinationGreeterAuthenticatedTestUnit is TestHelper {
  DestinationGreeterAuthenticated public target;
  address public source = address(bytes20(keccak256("Mock SourceGreeterAuthenticated")));
  address public notOriginSender = address(bytes20(keccak256("NotOriginSender")));
  bytes32 public transferId = keccak256("12345");
  uint32 public amount = 0;

  function setUp() public override {
    super.setUp();

    target = new DestinationGreeterAuthenticated(GOERLI_DOMAIN_ID, source, MOCK_CONNEXT);

    vm.label(address(target), "DestinationGreeterAuthenticated");
    vm.label(source, "Mock SourceGreeterAuthenticated");
  }

  function test_DestinationGreeterAuthenticated__xReceive_shouldUpdateGreeting(string memory newGreeting) public {
    vm.prank(MOCK_CONNEXT);

    target.xReceive(transferId, amount, MOCK_ERC20, source, GOERLI_DOMAIN_ID, abi.encode(newGreeting));

    assertEq(target.greeting(), newGreeting);
  }

  function test_DestinationGreeterAuthenticated__xReceive_shouldRevertIfNotFromOriginSender(
    string memory newGreeting
  ) public {
    vm.prank(MOCK_CONNEXT);

    vm.expectRevert("Expected original caller to be source contract on origin domain and this to be called by Connext");

    target.xReceive(transferId, amount, MOCK_ERC20, notOriginSender, GOERLI_DOMAIN_ID, abi.encode(newGreeting));
  }

  function test_DestinationGreeterAuthenticated__xReceive_shouldRevertIfNotFromOrigin(
    string memory newGreeting
  ) public {
    vm.prank(MOCK_CONNEXT);

    vm.expectRevert("Expected original caller to be source contract on origin domain and this to be called by Connext");

    target.xReceive(transferId, amount, MOCK_ERC20, source, POLYGON_MUMBAI_DOMAIN_ID, abi.encode(newGreeting));
  }
}
