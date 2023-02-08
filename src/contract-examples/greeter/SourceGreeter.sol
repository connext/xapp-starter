pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISourceGreeter {
  function updateGreeting (
    address token,
    address target, 
    uint32 destinationDomain,
    string memory newGreeting,
    uint256 slippage, 
    uint256 relayerFee
  ) external payable;
}

/**
 * @title SourceGreeter
 * @notice Example source contract that updates a greeting on DestinationGreeter. Requires 1 TEST to update.
 */
contract SourceGreeter {
  // The connext contract on the origin domain
  IConnext public immutable connext;

  // Hardcoded cost to update the greeting, in wei units
  // Exactly 0.05% above 1 TEST to account for router fees
  uint256 public cost = 1.0005003e18;

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /** @notice Updates a greeting variable on the DestinationGreeter contract.
    * @param token Address of the token on this domain.
    * @param target Address of the DestinationGreeter contract.
    * @param destinationDomain The destination domain ID.
    * @param newGreeting New greeting to update to.
    * @param relayerFee The fee offered to relayers.
    */
  function updateGreeting (
    address token,
    address target, 
    uint32 destinationDomain,
    string memory newGreeting,
    uint256 slippage, 
    uint256 relayerFee
  ) external payable {
    IERC20 _token = IERC20(token);

    require(
      _token.allowance(msg.sender, address(this)) >= cost,
      "User must approve amount"
    );

    // User sends funds to this contract
    _token.transferFrom(msg.sender, address(this), cost);

    // This contract approves transfer to Connext
    _token.approve(address(connext), cost);

    // Encode the data needed for the target contract call.
    bytes memory callData = abi.encode(newGreeting);

    connext.xcall{value: relayerFee}(
      destinationDomain, // _destination: Domain ID of the destination chain
      target,            // _to: address of the target contract
      token,             // _asset: address of the token contract
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      cost,              // _amount: amount of tokens to transfer
      slippage,          // _slippage: the maximum amount of slippage the user will accept in BPS (e.g. 30 = 0.3%)
      callData           // _callData: the encoded calldata to send
    );
  }
}
