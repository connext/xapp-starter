// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IConnext} from "@connext/interfaces/core/IConnext.sol";

interface ISourceGreeterAuthenticated {
  function xUpdateGreeting (
    address target, 
    uint32 destinationDomain,
    string memory newGreeting,
    uint256 relayerFee
  ) external payable;
}

/**
 * @title SourceGreeterAuthenticated
 * @notice Example source contract that updates a greeting in DestinationGreeterAuthenticated.
 */
contract SourceGreeterAuthenticated {
  // The connext contract on the origin domain.
  IConnext public immutable connext;

  constructor(address _connext) {
    connext = IConnext(_connext);
  }

  /** @notice Updates a greeting variable on the DestinationGreeterAuthenticated contract.
    * @param target Address of the DestinationGreeterAuthenticated contract.
    * @param destinationDomain The destination domain ID.
    * @param newGreeting New greeting to update to.
    * @param relayerFee The fee offered to relayers.
    */
  function xUpdateGreeting (
    address target, 
    uint32 destinationDomain,
    string memory newGreeting,
    uint256 relayerFee
  ) external payable {
    // Encode the data needed for the target contract call.
    bytes memory callData = abi.encode(newGreeting);

    connext.xcall{value: relayerFee}(
      destinationDomain, // _destination: Domain ID of the destination chain
      target,            // _to: address of the target contract
      address(0),        // _asset: use address zero for 0-value transfers
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      0,                 // _amount: 0 because no funds are being transferred
      0,                 // _slippage: can be anything between 0-10000 because no funds are being transferred
      callData           // _callData: the encoded calldata to send
    );
  }
}