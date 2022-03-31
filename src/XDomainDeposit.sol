// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {IConnext} from "nxtp/interfaces/IConnext.sol";

/**
 * @title XDomainDeposit
 * @notice Example of a cross-domain deposit into Aave V3 Pool.
 */
contract XDomainDeposit {
  event DepositInitiated(address asset, address pool, address to);

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

    // The Aave Pool needs a mapping of domains to pools.
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

    // Encode function of the target contract
    bytes4 selector = bytes4(
      keccak256("deposit(address,uint256,address,uint16)")
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
