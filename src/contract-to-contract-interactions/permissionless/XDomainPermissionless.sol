// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

/**
 * @title XDomainPermissionless
 * @notice Example of cross-domain permissionless calls.
 */
contract XDomainPermissionless {
  event DepositInitiated(address asset, uint256 amount, address onBehalfOf);

  IConnext public immutable connext;

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /**
   * Call a function on a target contract, permissionlessly. 
   * @notice Uses calldata in an `xcall` to execute a function on a Target contract. This
  *          contract assists with encoding function selector 
   * @dev Initiates the Connext bridging flow with calldata to be used on the target contract.
   */
  function deposit(
    address to,
    address asset,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 amount
  ) external payable {
    ERC20 token = ERC20(asset);
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
      selector,
      asset,
      amount,
      msg.sender
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
