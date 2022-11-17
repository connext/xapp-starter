pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title HelloSource
 * @notice Example source contract that updates a greeting in HelloTarget.
 * @dev Must pay at least 1 TEST to update the greeting.
 */
contract HelloSource {
  // The connext contract on the origin domain
  IConnext public immutable connext;

  // Hardcoded cost to update the greeting, in wei units
  // Exactly 0.05% above 1 TEST to account for router fees
  uint256 public cost = 1.0005003e18;

  // The canonical TEST Token on Goerli
  IERC20 public token = IERC20(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /** @notice Updates a greeting variable on the HelloTarget contract.
    * @param target Address of the HelloTarget contract.
    * @param destinationDomain The destination domain ID.
    * @param newGreeting New greeting to update to.
    * @param relayerFee The fee offered to relayers. On testnet, this can be 0.
    */
  function updateGreeting (
    address target, 
    uint32 destinationDomain,
    string memory newGreeting,
    uint256 relayerFee
  ) external {
    require(
      token.allowance(msg.sender, address(this)) >= cost,
      "User must approve amount"
    );

    // User sends funds to this contract
    token.transferFrom(msg.sender, address(this), cost);

    // This contract approves transfer to Connext
    token.approve(address(connext), cost);

    // Encode the data needed for the target contract call.
    bytes memory callData = abi.encode(newGreeting);

    connext.xcall{value: relayerFee}(
      destinationDomain, // _destination: Domain ID of the destination chain
      target,            // _to: address of the target contract
      address(token),    // _asset: address of the token contract
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      cost,              // _amount: amount of tokens to transfer
      30,                // _slippage: the max slippage the user will accept in BPS (0.3%)
      callData           // _callData: the encoded calldata to send
    );
  }
}
