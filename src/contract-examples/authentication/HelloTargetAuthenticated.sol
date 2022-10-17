// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";

contract HelloTargetAuthenticated is IXReceiver {
  string public greeting;

  /// The origin Domain ID
  uint32 public originDomain;

  /// The source contract
  address public sourceContract;

  /// The address of the Connext contract
  IConnext public connext;

  /** @notice A modifier for authenticated calls.
   *          This is an important security consideration. If the target contract
   *          function should be authenticated, it must check three things:
   *            1) The originating call comes from the expected origin domain.
   *            2) The originating call comes from the expected source contract.
   *            3) The call to this contract comes from Connext.
   */
  modifier onlySource(address _originSender, uint32 _origin) {
    require(
      _origin == originDomain &&
        _originSender == sourceContract &&
        msg.sender == address(connext),
      "Expected source contract on origin domain called by Connext"
    );
    _;
  }

  constructor(
    uint32 _originDomain,
    address _sourceContract,
    IConnext _connext
  ) {
    originDomain = _originDomain;
    sourceContract = _sourceContract;
    connext = _connext;
  }

  /// @notice Authenticated receiver function.
  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external onlySource(_originSender, _origin) returns (bytes memory) {
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
