// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Ping} from "../../ping-pong/Ping.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";

/**
 * @title PingTestUnit
 * @notice Unit tests for Ping.
 */
contract PingTestUnit is DSTestPlus {
  Ping public ping;
  IConnext public connext = IConnext(address(0xC));
  address public pong = address(0xD);
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    ping = new Ping(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(ping), "Ping");
    vm.label(pong, "Pong");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_xReceive_ShouldUpdatePongs(bytes32 transferId, uint256 pings) public {
    uint256 pongs = 0;

    ping.xReceive(transferId, 0, address(0), pong, OPTIMISM_GOERLI_DOMAIN_ID, abi.encode(pings));

    assertEq(ping.pongs(), pongs + 1);
  }

  function test_sendPing_ShouldRevertIfInsufficientRelayerFee() public {
    uint256 relayerFee = 1e16;

    vm.expectRevert(bytes("Must send gas equal to the specified relayer fee"));

    ping.sendPing{value: relayerFee - 1}(pong, OPTIMISM_GOERLI_DOMAIN_ID, relayerFee);
  }
}
