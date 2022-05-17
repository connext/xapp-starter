// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {Target} from "../../with-calldata/Target.sol";
import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";
import {ConnextHandler} from "nxtp/nomad-xapps/contracts/connext/ConnextHandler.sol";
import {IExecutor} from "nxtp/interfaces/IExecutor.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";
import "forge-std/Test.sol";

/**
 * @title TargetTestUnit
 *stUni @notice Unit tests for Target.
 */
contract TargetTestUnit is DSTestPlus {
  using stdStorage for StdStorage;

  MockERC20 private token;
  ConnextHandler private connext;
  address private source = address(1);
  Target private target;

  event UpdateCompleted(address sender, uint256 newValue, bool permissioned);

  function setUp() public {
    connext = new ConnextHandler();
    token = new MockERC20("TestToken", "TT", 18);
    target = new Target(source, rinkebyChainId, IConnextHandler(connext));

    vm.label(address(this), "TestContract");
    vm.label(address(connext), "Connext");
    vm.label(address(token), "TestToken");
    vm.label(address(target), "Target");
  }

  function testUpdateUnpermissionedEmitsUpdateCompleted() public {
    uint256 newValue = 100;

    vm.expectEmit(true, true, true, true);
    emit UpdateCompleted(address(this), newValue, false);

    target.updateValueUnpermissioned(newValue);
  }

  function testUpdateUnpermissionedSucceeds() public {
    uint256 newValue = 100;

    target.updateValueUnpermissioned(newValue);
    assertEq(target.value(), newValue);
  }

  function testUpdatePermissionedRevertsOnExecutorCheck() public {
    uint256 newValue = 100;

    vm.mockCall(
      address(IExecutor(address(this))), 
      abi.encodeWithSelector(
        IExecutor(address(this)).originSender.selector
      ), 
      abi.encode(source)
    );

    vm.mockCall(
      address(IExecutor(address(this))), 
      abi.encodeWithSelector(
        IExecutor(address(this)).origin.selector
      ), 
      abi.encode(rinkebyChainId)
    );

    vm.expectRevert("Expected origin contract on origin domain called by Executor");
    target.updateValuePermissioned(newValue);
  }

  function testUpdatePermissionedSucceeds() public {
    uint256 newValue = 100;

    vm.mockCall(
      address(IExecutor(address(this))), 
      abi.encodeWithSelector(
        IExecutor(address(this)).originSender.selector
      ), 
      abi.encode(source)
    );

    vm.mockCall(
      address(IExecutor(address(this))), 
      abi.encodeWithSelector(
        IExecutor(address(this)).origin.selector
      ), 
      abi.encode(rinkebyChainId)
    );

    stdstore
      .target(address(target))
      .sig("executor()")
      .checked_write(address(this));

    target.updateValuePermissioned(newValue);
  }

}