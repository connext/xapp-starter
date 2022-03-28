// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import { IPool } from "@aave/contracts/interfaces/IPool.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
  * @title XDomainDepositMiddleware
  * @notice Middleware contract for calling Aave V3 Pool on receiving chain.
  */
contract XDomainDepositMiddleware {
  event DepositCompleted(address asset, address pool, address to);

  function deposit(
    address pool, 
    address asset, 
    address onBehalfOf
  ) external {
    IERC20 token = IERC20(asset);

    uint256 amount = token.balanceOf(msg.sender);
    token.transferFrom(msg.sender, address(this), amount);

    token.approve(pool, amount);

    IPool(pool).supply(asset, amount, onBehalfOf, 0);

    emit DepositCompleted(asset, pool, onBehalfOf);
  }
}