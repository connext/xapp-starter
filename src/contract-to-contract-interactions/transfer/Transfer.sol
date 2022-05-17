// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";
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
    IConnextHandler.CallParams memory callParams = IConnextHandler.CallParams({
      to: to,
      callData: "",
      originDomain: originDomain,
      destinationDomain: destinationDomain,
      forceSlow: false,
      receiveLocal: false
    });

    IConnextHandler.XCallArgs memory xcallArgs = IConnextHandler.XCallArgs({
      params: callParams,
      transactingAssetId: asset,
      amount: amount,
      relayerFee: 0
    });

    connext.xcall(xcallArgs);

    emit TransferInitiated(asset, msg.sender, to);
  }
}
