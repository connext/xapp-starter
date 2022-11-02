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
  IConnext public connext = IConnext(address(1));
  address public ping = address(2);
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

  function test_sendPongShouldWork(uint256 amount) public {
    // Assume pong received tokens from Ping's xcall
    token.mint(address(pong), amount);

    // sendPong will be executed by Connext
    vm.startPrank(address(connext));

    // Mock the xcall
    bytes memory xcall = abi.encodeWithSelector(
      IConnext.xcall.selector
    );
    vm.mockCall(address(connext), xcall, abi.encode(1));

    // Test that xcall is called
    vm.expectCall(
      address(connext), 
      abi.encodeCall(
        IConnext.xcall, 
        (
          POLYGON_MUMBAI_DOMAIN_ID,
          ping,
          address(token),
          address(connext),
          amount,
          30,
          abi.encode(0)
        )
      )
    );

    pong.sendPong(
      POLYGON_MUMBAI_DOMAIN_ID,
      ping,
      address(token),
      amount,
      0
    );

    vm.stopPrank();
  }

  function test_xReceive_ShouldUpdatePings(
    bytes32 transferId, 
    uint256 amount, 
    uint32 domain, 
    uint256 pongs, 
    uint256 relayerFee
  ) public {
    // Mock the nested xcall
    bytes memory xcall = abi.encodeWithSelector(
      IConnext.xcall.selector
    );
    vm.mockCall(address(connext), xcall, abi.encode(1));

    uint256 pings = 0;

    pong.xReceive(transferId, amount, address(token), ping, domain, abi.encode(pongs, address(ping), relayerFee));
    assertEq(pong.pings(), pings + 1);
  }
}
