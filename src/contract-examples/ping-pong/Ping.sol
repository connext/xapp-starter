// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPing {
  function sendPing(
    address target, 
    uint32 destinationDomain, 
    uint256 relayerFee
  ) external payable;
}

/**
 * @title Ping
 * @notice Ping side of a PingPong example.
 */
contract Ping is IXReceiver {
  // Number of pongs this contract has received from the Pong contract
  uint256 public pongs;

  // The connext contract deployed on the same domain as this contract
  IConnext public immutable connext;

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /** 
   * @notice Sends a ping to the Pong contract.
   * @param destinationDomain The destination domain ID. 
   * @param target Address of the Pong contract on the destination domain.
   * @param relayerFee The fee offered to relayers.
   */
  function sendPing(
    address target, 
    uint32 destinationDomain, 
    uint256 relayerFee
  ) external payable {
    require(
      msg.value == relayerFee,
      "Must send gas equal to the specified relayer fee"
    );

    // Include the relayerFee so Pong will use the same fee 
    // Include the address of this contract so Pong will know where to send the "callback"
    bytes memory callData = abi.encode(pongs, address(this), relayerFee);

    connext.xcall{value: relayerFee}(
      destinationDomain, // _destination: domain ID of the destination chain
      target,            // _to: address of the target contract (Pong)
      address(0),        // _asset: use address zero for 0-value transfers
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      0,                 // _amount: 0 because no funds are being transferred
      0,                 // _slippage: can be anything between 0-10000 because no funds are being transferred
      callData           // _callData: the encoded calldata to send
    );
  }

  /** @notice The receiver function as required by the IXReceiver interface.
   * @dev The "callback" function for this example. Will be triggered after Pong xcalls back.
   */
  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external returns (bytes memory) {
    uint256 _pings = abi.decode(_callData, (uint256));

    pongs++;
  }
}
