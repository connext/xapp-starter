// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";

/**
 * @title XDomainPermissioned
 * @notice Example of a cross-domain permissioned call.
 */
contract XDomainPermissioned {
  event UpdateInitiated(address asset, uint256 newValue, address onBehalfOf);

  IConnextHandler public immutable connext;

  constructor(IConnextHandler _connext) {
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
    uint256 newValue
  ) external payable {
    // Encode function of the target contract (from PermissionedTarget.sol)
    // In this case: updateValue(uint256 newValue)
    bytes4 selector = bytes4(keccak256("updateValue(uint256)"));
    bytes memory callData = abi.encodeWithSelector(selector, newValue);

    IConnextHandler.CallParams memory callParams = IConnextHandler.CallParams({
      to: to,
      callData: callData,
      originDomain: originDomain,
      destinationDomain: destinationDomain,
      forceSlow: true,
      receiveLocal: false
    });

    IConnextHandler.XCallArgs memory xcallArgs = IConnextHandler.XCallArgs({
      params: callParams,
      transactingAssetId: asset,
      amount: 0,
      relayerFee: 0
    });

    connext.xcall(xcallArgs);

    emit UpdateInitiated(asset, newValue, msg.sender);
  }
}
