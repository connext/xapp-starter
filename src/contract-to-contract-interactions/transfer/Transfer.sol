// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import {CallParams, XCallArgs} from "nxtp/core/connext/libraries/LibConnextStorage.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

/**
 * @title Transfer
 * @notice Example of a cross-domain transfer.
 */
contract Transfer {
  event TransferInitiated(address asset, address from, address to);

  IConnextHandler public immutable connext;

  constructor(IConnextHandler _connext) {
    connext = _connext;
  }

  /**
   * Simple transfer of funds.
   * @notice This simple example is not terribly useful in practice but it demonstrates
   *         how to use `xcall` to transfer funds from a user on one chain to a receiving
   *         address on another.
   * @dev For list of Nomad Domain IDs, see: https://docs.nomad.xyz/bridge/domains.html
   * @param to The destination address (e.g. a wallet)
   * @param asset Address of token on origin domain 
   * @param originDomain The origin domain ID (e.g. 2111 for Kovan)
   * @param destinationDomain The origin domain ID (e.g. 1111 for Rinkeby)
   * @param amount The amount to transfer
   */
  function transfer(
    address to,
    address asset,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 amount
  ) external {
    ERC20 token = ERC20(asset);
    require(
      token.allowance(msg.sender, address(this)) >= amount,
      "User must approve amount"
    );

    // User sends funds to this contract
    token.transferFrom(msg.sender, address(this), amount);

    // This contract approves transfer to Connext
    token.approve(address(connext), amount);

    // Empty callData because this is a simple transfer of funds
    CallParams memory callParams = CallParams({
      to: to,
      callData: "", // empty here because we're only sending funds
      originDomain: originDomain, 
      destinationDomain: destinationDomain,
      recovery: to, // fallback address to send funds to if execution fails on destination side
      callback: address(0), // zero address because we don't expect a callback
      callbackFee: 0, // fee paid to relayers; relayers don't take any fees on testnet
      forceSlow: false, // option that allows users to take the Nomad slow path (~30 mins) instead of paying routers a 0.05% fee on their transaction
      receiveLocal: false // option for users to receive the local Nomad-flavored asset instead of the adopted asset on the destination side
    });

    XCallArgs memory xcallArgs = XCallArgs({
      params: callParams,
      transactingAssetId: asset,
      amount: amount,
      relayerFee: 0 // fee paid to relayers; relayers don't take any fees on testnet
    });

    connext.xcall(xcallArgs);

    emit TransferInitiated(asset, msg.sender, to);
  }
}
