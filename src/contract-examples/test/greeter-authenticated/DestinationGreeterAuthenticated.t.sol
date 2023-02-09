// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {DestinationGreeterAuthenticated} from "../../greeter-authenticated/DestinationGreeterAuthenticated.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {TestHelper} from "../utils/TestHelper.sol";

/**
 * @title DestinationGreeterAuthenticatedTestUnit
 *stUni @notice Unit tests for DestinationGreeterAuthenticated.
 */
contract DestinationGreeterAuthenticatedTestUnit is TestHelper {
  DestinationGreeterAuthenticated public target;
  address public source = address(bytes20(keccak256("Mock SourceGreeterAuthenticated")));

  bytes4 public originSenderSelector = bytes4(keccak256("originSender(bytes)"));
  bytes4 public originSelector = bytes4(keccak256("origin(bytes)"));

  function setUp() public override {
    super.setUp();

    target = new DestinationGreeterAuthenticated(GOERLI_DOMAIN_ID, source, MOCK_CONNEXT);

    vm.label(address(target), "DestinationGreeterAuthenticated");
    vm.label(source, "Mock SourceGreeterAuthenticated");
  }

  function test_DestinationGreeterAuthenticated__xReceive_shouldUpdateGreeting(bytes32 transferId, uint256 amount, string memory newGreeting) public {
    vm.prank(MOCK_CONNEXT);

    target.xReceive(transferId, amount, MOCK_ERC20, source, GOERLI_DOMAIN_ID, abi.encode(newGreeting));

    assertEq(target.greeting(), newGreeting);
  }
}
