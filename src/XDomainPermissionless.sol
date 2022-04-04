// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title XDomainPermissionless
 * @notice Example of a cross-domain permissionless call.
 */
contract XDomainPermissionless {
  event DepositInitiated(address asset, uint256 amount, address onBehalfOf);

  IConnext public immutable connext;

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /**
   * Deposit funds from one chain to another.
   @dev Initiates the Connext bridging flow with calldata to be used on the target contract.
   */
  function deposit(
    address to,
    address asset,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 amount
  ) external payable {
    MockERC20 token = MockERC20(asset);
    require(token.allowance(msg.sender, address(this)) >= amount, "User must approve amount");

    // User sends funds to this contract
    token.transferFrom(msg.sender, address(this), amount);

    // This contract approves transfer to Connext
    token.approve(address(connext), amount);

    // Encode function of the target contract (from Target.sol)
    // In this case: deposit(address asset, uint256 amount, address onBehalfOf)
    bytes4 selector = bytes4(
      keccak256("deposit(address,uint256,address)")
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
      amount: amount
    });

    connext.xcall(xcallArgs);

    emit DepositInitiated(asset, amount, msg.sender);
  }
}
