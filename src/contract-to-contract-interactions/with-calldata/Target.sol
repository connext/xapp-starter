// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import {IExecutor} from "nxtp/core/connext/interfaces/IExecutor.sol";
import {LibCrossDomainProperty} from "nxtp/core/connext/libraries/LibCrossDomainProperty.sol";

/**
 * @title Target
 * @notice A contrived example target contract.
 */
contract Target {
  event UpdateCompleted(address sender, uint256 newValue, bool authenticated);

  uint256 public value;

  // The address of Source.sol
  address public originContract;

  // The origin Domain ID
  uint32 public originDomain;

  // The address of the Connext Executor contract
  IExecutor public executor;

  // A modifier for authenticated function calls.
  // Note: This is an important security consideration. If your target
  //       contract function is meant to be authenticated, it must check
  //       that the originating call is from the correct domain and contract.
  //       Also, it must be coming from the Connext Executor address.
  modifier onlyExecutor() {
    require(
      LibCrossDomainProperty.originSender(msg.data) == originContract &&
        LibCrossDomainProperty.origin(msg.data) == originDomain &&
        msg.sender == address(executor),
      "Expected origin contract on origin domain called by Executor"
    );
    _;
  }

  constructor(
    address _originContract,
    uint32 _originDomain,
    IConnextHandler _connext
  ) {
    originContract = _originContract;
    originDomain = _originDomain;
    executor = _connext.executor();
  }

  // Unauthenticated function
  function updateValueUnauthenticated(uint256 newValue) 
    external 
    returns (uint256)
  {
    value = newValue;

    emit UpdateCompleted(msg.sender, newValue, false);
    return newValue;
  }

  // Authenticated function
  function updateValueAuthenticated(uint256 newValue) 
    external onlyExecutor 
    returns (uint256)
  {
    value = newValue;

    emit UpdateCompleted(msg.sender, newValue, true);
    return newValue;
  }
}
