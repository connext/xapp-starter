// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import {ICallback} from "nxtp/core/promise/interfaces/ICallback.sol";
import {CallParams, XCallArgs} from "nxtp/core/connext/libraries/LibConnextStorage.sol";

/**
 * @title Source
 * @notice Example contract for cross-domain calls (xcalls).
 */
contract Source is ICallback {
  event UpdateInitiated(address to, uint256 newValue, bool authenticated);
  event CallbackCalled(bytes32 transferId, bool success, uint256 newValue); 

  IConnextHandler public immutable connext;
  address public immutable promiseRouter;

  // A modifier for permissioning the callback.
  // Note: This is an important security consideration. Only the PromiseRouter (the
  //       Connext contract that executes the callback function) should be able to
  //       call the callback function.
  modifier onlyPromiseRouter () {
    require(
      msg.sender == address(promiseRouter),
      "Expected PromiseRouter"
    );
    _;
  }

  constructor(IConnextHandler _connext, address _promiseRouter) {
    connext = _connext;
    promiseRouter = _promiseRouter;
  }

  /**
   * Cross-domain update of a value on a target contract.
   @dev Initiates the Connext bridging flow with calldata to be used on the target contract.
   */
  function xChainUpdate(
    address to,
    uint32 originDomain,
    uint32 destinationDomain,
    uint256 newValue,
    bool authenticated
  ) external payable {
    bytes4 selector;
    bool forceSlow;

    // Encode function of the target contract (from Target.sol)
    if (authenticated) {
      selector = bytes4(keccak256("updateValueAuthenticated(uint256)"));
      forceSlow = true;
    } else {
      selector = bytes4(keccak256("updateValueUnauthenticated(uint256)"));
      forceSlow = false;
    }
    bytes memory callData = abi.encodeWithSelector(selector, newValue);

    CallParams memory callParams = CallParams({
      to: to,
      callData: callData,
      originDomain: originDomain,
      destinationDomain: destinationDomain,
      agent: msg.sender, // address allowed to execute transaction on destination side in addition to relayers
      recovery: msg.sender, // fallback address to send funds to if execution fails on destination side
      forceSlow: forceSlow, // option to force slow path instead of paying 0.05% fee on fast liquidity transfers
      receiveLocal: false, // option to receive the local bridge-flavored asset instead of the adopted asset
      callback: address(this), // this contract implements the callback
      callbackFee: 0, // fee paid to relayers for the callback; no fees on testnet
      relayerFee: 0, // fee paid to relayers for the forward call; no fees on testnet
      destinationMinOut: 0 // not sending funds so minimum can be 0
    });

    XCallArgs memory xcallArgs = XCallArgs({
      params: callParams,
      transactingAsset: address(0), // 0 address is the native gas token
      transactingAmount: 0, // not sending funds with this calldata-only xcall
      originMinOut: 0 // not sending funds so minimum can be 0
    });

    connext.xcall(xcallArgs);

    emit UpdateInitiated(to, newValue, authenticated);
  }

  /**
   * Callback function required for contracts implementing the ICallback interface.
   @dev This function is called to handle return data from the destination domain.
   */ 
  function callback(
    bytes32 transferId,
    bool success,
    bytes memory data
  ) external onlyPromiseRouter {
    uint256 newValue = abi.decode(data, (uint256));
    emit CallbackCalled(transferId, success, newValue);
  }
}
