// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {TestHelper} from "../utils/TestHelper.sol";
import {DestinationGreeter} from "../../greeter/DestinationGreeter.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DestinationGreeterTestUnit
 *stUni @notice Unit tests for DestinationGreeter.
 */
contract DestinationGreeterTestUnit is TestHelper {
  DestinationGreeter public target;
  address public source = address(bytes20(keccak256("Mock SourceGreeter")));
  uint256 public cost = 1e18;
  bytes32 public transferId = keccak256("12345");
  address public wrongAsset = address(bytes20(keccak256("wrong asset")));

  function setUp() public override {
    super.setUp();

    target = new DestinationGreeter(MOCK_ERC20);

    vm.label(address(target), "DestinationGreeter");
    vm.label(source, "Mock SourceGreeter");
  }

  function test_DestinationGreeter__xReceive_shouldUpdateGreeting(
    uint256 amount, 
    string memory newGreeting
  ) public {
    amount = bound(amount, 1e18, 1e36);

    target.xReceive(transferId, amount, MOCK_ERC20, source, GOERLI_DOMAIN_ID, abi.encode(newGreeting));

    assertEq(target.greeting(), newGreeting);
  }

  function test_DestinationGreeter__xReceive_shouldRevertIfAmountUnderCost(
    string memory newGreeting
  ) public {
    uint256 amount = 0;

    vm.expectRevert(abi.encodePacked("Must pay at least 1 wei"));

    target.xReceive(transferId, amount, MOCK_ERC20, source, GOERLI_DOMAIN_ID, abi.encode(newGreeting));
  }

  function test_DestinationGreeter__xReceive_shouldRevertIfWrongAsset(
    uint256 amount, 
    string memory newGreeting
  ) public {
    amount = bound(amount, 1, 1e36);

    vm.expectRevert(abi.encodePacked("Wrong asset received"));

    target.xReceive(transferId, amount, wrongAsset, source, GOERLI_DOMAIN_ID, abi.encode(newGreeting));
  }
}
