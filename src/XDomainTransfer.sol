// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

/**
 * @title XDomainTransfer
 * @notice Example of a cross-domain transfer.
 */
contract XDomainTransfer {
  event TransferInitiated(address asset, address from, address to);

  IConnext public immutable connext;

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /**
    * Transfer funds from one chain to another.
    @dev Initiates the Connext bridging flow. For list of Nomad Domain IDs, see:
    *    https://docs.nomad.xyz/bridge/domains.html
    */
  function transfer(
    address to,
    address asset,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 amount
  ) external {
    // empty callData because this is a simple transfer of funds
    IConnext.CallParams memory callParams = IConnext.CallParams({
      to: to,
      callData: "",
      originDomain: originDomain,
      destinationDomain: destinationDomain
    });

    IConnext.XCallArgs memory xcallArgs = IConnext.XCallArgs({
      params: callParams,
      transactingAssetId: asset,
      amount: amount
    });

    connext.xcall(xcallArgs);

    emit TransferInitiated(asset, msg.sender, to);
  }
}
