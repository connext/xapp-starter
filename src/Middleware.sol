// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {IExecutor} from "nxtp/interfaces/IExecutor.sol";
import {IPermissionedTarget} from "./PermissionedTarget.sol";

/**
 * @title Middleware
 * @notice A middleware contract to check permissioned functions.
 */
contract Middleware {
  // The address of xDomainPermissioned.sol
  address public originContract;

  // The origin Domain ID 
  uint32 public originDomain;

  constructor(address _originContract, uint32 _originDomain) {
    originContract = _originContract; 
    originDomain = _originDomain;
  }

  /**
   * Intermediate function for calling a target contract.
   @dev Checks that the originating call is from the correct domain and sender.
   */
  function updateValue(IPermissionedTarget target, address asset, uint256 value) external returns (uint256) {
    require(
      // origin domain of the source contract 
      IExecutor(msg.sender).origin() == originDomain,
      "Expected origin domain"
    );
    require(
      // msg.sender of xcall from the origin domain
      IExecutor(msg.sender).originSender() == originContract,
      "Expected origin domain contract"
    );

    target.updateValue(value);
  }
}
