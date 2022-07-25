// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import {Target} from "../../with-calldata/Target.sol";
import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import {IExecutor} from "nxtp/core/connext/interfaces/IExecutor.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import "forge-std/Test.sol";

/**
 * @title TargetTestUnit
 *stUni @notice Unit tests for Target.
 */
contract TargetTestUnit is DSTestPlus {
  using stdStorage for StdStorage;

  address private connext = address(1);
  address private source = address(2);
  Target private target;

  event UpdateCompleted(address sender, uint256 newValue, bool authenticated);

  function setUp() public {
    vm.mockCall(
      address(connext),
      abi.encodeWithSelector(IConnextHandler.executor.selector),
      abi.encode(address(3))
    );

    target = new Target(source, rinkebyChainId, IConnextHandler(connext));

    vm.label(address(this), "TestContract");
    vm.label(connext, "Connext");
    vm.label(source, "Target");
    vm.label(address(target), "Target");
  }

  function testUpdateUnauthenticatedEmitsUpdateCompleted() public {
    uint256 newValue = 100;

    vm.expectEmit(true, true, true, true);
    emit UpdateCompleted(address(this), newValue, false);

    target.updateValueUnauthenticated(newValue);
  }

  function testUpdateUnauthenticatedSucceeds() public {
    uint256 newValue = 100;

    target.updateValueUnauthenticated(newValue);
    assertEq(target.value(), newValue);
  }

  function testUpdateAuthenticatedRevertsOnExecutorCheck() public {
    uint256 newValue = 100;

    vm.mockCall(
      address(IExecutor(address(this))),
      abi.encodeWithSelector(IExecutor(address(this)).originSender.selector),
      abi.encode(source)
    );

    vm.mockCall(
      address(IExecutor(address(this))),
      abi.encodeWithSelector(IExecutor(address(this)).origin.selector),
      abi.encode(rinkebyChainId)
    );

    vm.expectRevert(
      "Expected origin contract on origin domain called by Executor"
    );
    target.updateValueAuthenticated(newValue);
  }

  function testUpdateAuthenticatedSucceeds() public {
    uint256 newValue = 100;

    vm.mockCall(
      address(IExecutor(address(this))),
      abi.encodeWithSelector(IExecutor(address(this)).originSender.selector),
      abi.encode(source)
    );

    vm.mockCall(
      address(IExecutor(address(this))),
      abi.encodeWithSelector(IExecutor(address(this)).origin.selector),
      abi.encode(rinkebyChainId)
    );

    stdstore.target(address(target)).sig("executor()").checked_write(
      address(this)
    );

    target.updateValueAuthenticated(newValue);
  }
}
