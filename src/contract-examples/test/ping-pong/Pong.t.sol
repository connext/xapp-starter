// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {TestHelper} from "../utils/TestHelper.sol";
import {Pong} from "../../ping-pong/Pong.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";

/**
 * @title PongTestUnit
 * @notice Unit tests for Pong.
 */
contract PongTestUnit is TestHelper {
  Pong public pong;
  address public ping = address(bytes20(keccak256("Mock Ping")));
  uint256 public amount = 0;
  uint256 public slippage = 0;
  bytes32 public transferId = keccak256("12345");
  uint256 public relayerFee = 1e16;
  address public asset = address(0);

  function setUp() public override {
    super.setUp();
    
    pong = new Pong(IConnext(MOCK_CONNEXT));

    vm.label(address(pong), "Pong");
    vm.label(ping, "Mock Ping");
  }

  function test_Pong__xReceive_shouldUpdatePings() public {
    // Deal Pong native gas to cover relayerFee
    vm.deal(address(pong), relayerFee);

    uint256 pings = 0;
    uint256 pongs = 0;

    // Mock the nested xcall
    vm.mockCall(
      MOCK_CONNEXT, 
      relayerFee,
      abi.encodeCall(
        IConnext.xcall, 
        (
          GOERLI_DOMAIN_ID,
          ping,
          asset,
          address(this),
          amount,
          slippage,
          abi.encode(pings + 1)
        )
      ),
      abi.encode(transferId)
    );

    pong.xReceive(
      transferId, 
      amount, 
      asset, 
      ping, 
      GOERLI_DOMAIN_ID, 
      abi.encode(pongs, ping, relayerFee)
    );

    assertEq(pong.pings(), pings + 1);
  }

  function test_Pong__xReceive_shouldRevertIfNotEnoughGasForRelayerFee(
    uint256 pongs
  ) public {
    vm.expectRevert(bytes("Not enough gas to pay for relayer fee"));

    pong.xReceive(
      transferId, 
      amount, 
      asset, 
      ping, 
      GOERLI_DOMAIN_ID, 
      abi.encode(pongs, address(ping), relayerFee)
    );
  }
}
