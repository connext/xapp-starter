// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import { IConnext } from "./IConnext.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

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
    @dev Initiates the Connext bridging flow. 
    */
  function transfer(
    address to,
    address asset,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 amount
  ) external {

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
