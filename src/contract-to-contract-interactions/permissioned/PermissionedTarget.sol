// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPermissionedTarget {
  function updateValue(uint256 newValue) external;
}

/**
 * @title PermissionedTarget
 * @notice A contrived example target contract.
 */
contract PermissionedTarget is IPermissionedTarget, Ownable {
  uint256 public value;
  address public middleware;

  constructor(address _middleware) {
    middleware = _middleware;
    _transferOwnership(middleware);
  }

  // Permissioned function - permissioning should be upheld by a 
  // middleware contract.
  function updateValue(uint256 newValue) external override onlyOwner {
    value = newValue;
  }
}
