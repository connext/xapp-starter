// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title XDomainDeposit
 * @notice Example of a cross-domain deposit into Aave V3 Pool.
 * @dev Assume this is only for cross-domain deposits of DAI.
 */
contract XDomainDeposit {
  event DepositInitiated(address asset, address pool, address onBehalfOf);

  IConnext public immutable connext;
  mapping(uint32 => address) public pools;

  /**
   * Set up the relevant data needed by the external target contract, if necessary.
   */
  constructor(
    IConnext _connext,
    uint32[] memory _domains,
    address[] memory _pools
  ) {
    connext = _connext;

    // Keep a mapping of domains --> DAI pools.
    for (uint256 i = 0; i < _domains.length; i++) {
      pools[_domains[i]] = _pools[i];
    }
  }

  /**
   * Deposit funds from one chain to another.
   @dev Initiates the Connext bridging flow with calldata to be used on the target contract.
   */
  function deposit(
    address asset,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 amount,
    address onBehalfOf
  ) external {
    address pool = pools[destinationDomain];
    require(pool != address(0), "Pool does not exist");

    MockERC20 token = MockERC20(asset);
    require(token.allowance(msg.sender, address(this)) >= amount, "User must approve amount");

    // User sends funds to this contract
    token.transferFrom(msg.sender, address(this), amount);

    // This contract approves transfer to Connext
    token.approve(address(connext), amount);

    // Encode function of the target contract
    bytes4 selector = bytes4(
      keccak256("supply(address,uint256,address,uint16)")
    );
    bytes memory callData = abi.encodeWithSelector(
      selector,
      asset,
      pool,
      msg.sender
    );

    IConnext.CallParams memory callParams = IConnext.CallParams({
      to: pool,
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

    emit DepositInitiated(asset, pool, onBehalfOf);
  }
}
