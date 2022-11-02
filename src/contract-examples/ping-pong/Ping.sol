pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
   * @param token Address of the token on this domain.
   * @param amount The amount to transfer.
   * @param relayerFee The fee offered to relayers. On testnet, this can be 0.
   */
  function sendPing(
    uint32 destinationDomain, 
    address target, 
    address token,
    uint256 amount, 
    uint256 relayerFee
  ) external payable {
    IERC20 _token = IERC20(token);

    require(
      _token.allowance(msg.sender, address(this)) >= amount,
      "User must approve amount"
    );

    // User sends funds to this contract
    _token.transferFrom(msg.sender, address(this), amount);

    // This contract approves transfer to Connext
    _token.approve(address(connext), amount);

    // Include the relayerFee so Pong will use the same fee 
    // Include the address of this contract so Pong will know where to send the "callback"
    bytes memory _callData = abi.encode(pongs, address(this), relayerFee);

    connext.xcall{value: relayerFee}(
      destinationDomain, // _destination: domain ID of the destination chain
      target,            // _to: address of the target contract (Pong)
      token,             // _asset: address of the token contract
      msg.sender,        // _delegate: address that can revert or forceLocal on destination
      amount,            // _amount: amount of tokens to transfer
      30,                // _slippage: the maximum amount of slippage the user will accept in BPS, in this case 0.3%
      _callData          // _callData: the encoded calldata to send
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
