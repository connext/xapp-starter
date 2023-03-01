// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {TestHelper} from "../utils/TestHelper.sol";
import {Ping} from "../../ping-pong/Ping.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";

/**
 * @title PingTestUnit
 * @notice Unit tests for Ping.
 */
contract PingTestUnit is TestHelper {
  Ping public ping;
  address public pong = address(bytes20(keccak256("pong")));
  uint256 public amount = 0;
  bytes32 public transferId = keccak256("12345");
  uint256 public relayerFee = 1e16;
  address public asset = address(0);

  function setUp() public override {
    super.setUp();
    
    ping = new Ping(MOCK_CONNEXT);

    vm.label(address(ping), "Ping");
    vm.label(pong, "Mock Pong");
  }

  function test_Ping__xReceive_shouldUpdatePings(uint256 pongs) public {
    uint256 pings = 0;

    ping.xReceive(
      transferId, 
      amount, 
      asset, 
      pong, 
      OPTIMISM_GOERLI_DOMAIN_ID, 
      abi.encode(pongs)
    );

    assertEq(ping.pings(), pings + 1);
  }

  function test_Ping__startPingPong_shouldRevertIfInsufficientRelayerFee() public {

    vm.expectRevert(bytes("Must send gas equal to the specified relayer fee"));

    ping.startPingPong{value: relayerFee - 1}(pong, OPTIMISM_GOERLI_DOMAIN_ID, relayerFee);
  }
}
