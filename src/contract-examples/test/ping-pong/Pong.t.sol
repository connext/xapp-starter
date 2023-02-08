// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Pong} from "../../ping-pong/Pong.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title PongTestUnit
 * @notice Unit tests for Pong.
 */
contract PongTestUnit is DSTestPlus {
  Pong public pong;
  ERC20PresetMinterPauser public token;
  IConnext public connext = IConnext(address(0xC));
  address public ping = address(0xD);
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    token = new ERC20PresetMinterPauser("TestToken", "TEST");
    pong = new Pong(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(pong), "Pong");
    vm.label(ping, "Ping");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_xReceive_ShouldUpdatePings(
    bytes32 transferId, 
    uint32 domain, 
    uint256 pongs
  ) public {
    uint256 relayerFee = 1e16;
    vm.deal(address(pong), relayerFee);

    // Mock the nested xcall
    bytes memory xcall = abi.encodeWithSelector(
      IConnext.xcall.selector
    );
    vm.mockCall(address(connext), xcall, abi.encode(1));

    uint256 pings = 0;

    pong.xReceive(
      transferId, 
      0, 
      address(0), 
      ping, 
      OPTIMISM_GOERLI_DOMAIN_ID, 
      abi.encode(pongs, address(ping), relayerFee)
    );

    assertEq(pong.pings(), pings + 1);
  }

  function test_xReceive_ShouldRevertIfNotEnoughGasForRelayerFee(
    bytes32 transferId, 
    uint256 pongs
  ) public {
    uint256 relayerFee = 1e16;

    vm.expectRevert(bytes("Not enough gas to pay for relayer fee"));

    pong.xReceive(
      transferId, 
      0, 
      address(0), 
      ping, 
      OPTIMISM_GOERLI_DOMAIN_ID, 
      abi.encode(pongs, address(ping), relayerFee)
    );
  }
}
