pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TransferToken
 * @notice Example of a cross-domain token transfer.
 */
contract TransferToken {
  // The connext contract on the origin domain.
  IConnext public immutable connext;

  constructor(IConnext _connext) {
    connext = _connext;
  }

  /**
   * @notice Transfers funds from one chain to another.
   * @param recipient The destination address (e.g. a wallet).
   * @param destinationDomain The destination domain ID.
   * @param tokenAddress Address of the token to transfer.
   * @param amount The amount to transfer.
   * @param relayerFee The fee offered to relayers. On testnet, this can be 0.
   */
  function transfer(
    address recipient,
    uint32 destinationDomain,
    address tokenAddress,
    uint256 amount,
    uint256 relayerFee
  ) external payable {
    IERC20 token = IERC20(tokenAddress);
    require(
      token.allowance(msg.sender, address(this)) >= amount,
      "User must approve amount"
    );

    // User sends funds to this contract
    token.transferFrom(msg.sender, address(this), amount);

    // This contract approves transfer to Connext
    token.approve(address(connext), amount);

    connext.xcall{value: relayerFee}(
      destinationDomain, // _destination: Domain ID of the destination chain
      recipient,         // _to: address receiving the funds on the destination
      tokenAddress,      // _asset: address of the token contract
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      amount,            // _amount: amount of tokens to transfer
      3,                 // _slippage: the maximum amount of slippage the user will accept in BPS
      ""                 // _callData: empty because we're only sending funds
    );  
  }
}
