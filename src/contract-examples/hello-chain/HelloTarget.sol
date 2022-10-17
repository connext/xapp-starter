pragma solidity ^0.8.15;

import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";

contract HelloTarget is IXReceiver {
  string public greeting;

  /** @notice The receiver function as required by the IXReceiver interface.
    * @dev The Connext bridge contract will call this function.
    */
  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external returns (bytes memory) {
    _updateGreeting(_callData);
  }

  /** @notice Internal function to update the greeting.
    * @param _callData Calldata containing the new greeting.
    */
  function _updateGreeting(bytes memory _callData) internal {
    string memory newGreeting = abi.decode(_callData, (string));
    greeting = newGreeting;
  }
}