// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import {IExecutor} from "nxtp/interfaces/IExecutor.sol";
import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

/**
 * @title PermissionedTarget
 * @notice A contrived example target contract.
 */
contract PermissionedTarget {
  uint256 public value;

  // The address of xDomainPermissioned.sol
  address public originContract;

  // The origin Domain ID
  uint32 public originDomain;

  // The address of the Connext Executor contract
  address public executor;

  // A modifier for permissioned function calls.
  // Note: This is an important security consideration. If your target
  //       contract function is meant to be permissioned, it must check 
  //       that the originating call is from the correct domain and contract.
  //       Also, check that the msg.sender is the Connext Executor address.
  modifier onlyExecutor() {
    require(
      IExecutor(msg.sender).originSender() == originContract && 
      IExecutor(msg.sender).origin() == originDomain && 
      msg.sender == executor,
      "Expected origin contract on origin domain called by Executor"
    );
    _;
  } 

  constructor(
    address _originContract, 
    uint32 _originDomain, 
    address payable _connext
  ) {
    originContract = _originContract;
    originDomain = _originDomain;
    executor = IConnextHandler(_connext).getExecutor(); 
  }

  // Permissioned function
  function updateValue(uint256 newValue) external onlyExecutor {
    value = newValue;
  }
}
