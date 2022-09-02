// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

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
   * @dev For a reference to Domain IDs, see: https://docs.connext.network/developers/testing-against-testnet
   * @param to The destination address (e.g. a wallet)
   * @param asset Address of token on origin domain
   * @param originDomain The origin domain ID (e.g. 1735353714 for Goerli)
   * @param destinationDomain The origin domain ID (e.g. 1735356532 for Optimism-Goerli)
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

    CallParams memory callParams = CallParams({
      to: to,
      callData: "", // empty here because we're only sending funds
      originDomain: originDomain,
      destinationDomain: destinationDomain,
      agent: msg.sender, // address allowed to execute transaction on destination side in addition to relayers
      recovery: msg.sender, // fallback address to send funds to if execution fails on destination side
      forceSlow: false, // option to force slow path instead of paying 0.05% fee on fast path transfers
      receiveLocal: false, // option to receive the local bridge-flavored asset instead of the adopted asset
      callback: address(0), // zero address because we don't expect a callback
      callbackFee: 0, // fee paid to relayers; relayers don't take any fees on testnet
      relayerFee: 0, // fee paid to relayers; relayers don't take any fees on testnet
      destinationMinOut: (amount / 100) * 97 // the minimum amount that the user will accept due to slippage from the StableSwap pool (3% here)
    });

    XCallArgs memory xcallArgs = XCallArgs({
      params: callParams,
      transactingAsset: asset,
      transactingAmount: amount,
      originMinOut: (amount / 100) * 97 // the minimum amount that the user will accept due to slippage from the StableSwap pool (3% here)
    });

    connext.xcall(xcallArgs);

    emit TransferInitiated(asset, msg.sender, to);
  }
}
