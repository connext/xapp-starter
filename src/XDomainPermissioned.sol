// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnext} from "nxtp/interfaces/IConnext.sol";

/**
 * @title XDomainPermissioned
 * @notice Example of a cross-domain permissioned call.
 */
contract XDomainPermissioned {
  event UpdateInitiated(address asset, uint256 amount, address onBehalfOf);

  IConnext public immutable connext;

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /**
   * Updates a cross-chain value.
   @dev Initiates the Connext bridging flow with calldata to be used on the target contract.
   */
  function update(
    address to,
    address asset,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 amount
  ) external payable {
    // Encode function of the target contract
    // In this case, the target function is an intermediate function in Middleware.sol
    bytes4 selector = bytes4(
      keccak256("updateValue(uint256)")
    );
    bytes memory callData = abi.encodeWithSelector(
      selector
    );

    IConnext.CallParams memory callParams = IConnext.CallParams({
      to: to,
      callData: callData,
      originDomain: originDomain,
      destinationDomain: destinationDomain
    });

    IConnext.XCallArgs memory xcallArgs = IConnext.XCallArgs({
      params: callParams,
      transactingAssetId: asset,
      amount: 0
    });

    connext.xcall(xcallArgs);

    emit UpdateInitiated(asset, amount, msg.sender);
  }
}
