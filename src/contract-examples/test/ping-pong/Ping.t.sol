// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Ping} from "../../ping-pong/Ping.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title PingTestUnit
 * @notice Unit tests for Ping.
 */
contract PingTestUnit is DSTestPlus {
  Ping public ping;
  ERC20PresetMinterPauser public token;
  IConnext public connext = IConnext(address(1));
  address public pong = address(2);
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    token = new ERC20PresetMinterPauser("TestToken", "TEST");
    ping = new Ping(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(ping), "Ping");
    vm.label(pong, "Pong");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_sendPingShouldTransferFromCaller(uint256 amount) public {
    // Mint userChainA some tokens
    token.mint(userChainA, amount);

    vm.startPrank(userChainA);

    // userChainA must approve transfer to Ping contract
    token.approve(address(ping), amount);

    // Mock the xcall
    bytes memory xcall = abi.encodeWithSelector(
      IConnext.xcall.selector
    );
    vm.mockCall(address(connext), xcall, abi.encode(1));

    // Test that tokens are sent from userChainA to Ping contract
    vm.expectCall(
      address(token), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          userChainA, 
          address(ping),
          amount
        )
      )
    );

    ping.sendPing(
      POLYGON_MUMBAI_DOMAIN_ID,
      pong,
      address(token),
      amount,
      0
    );

    vm.stopPrank();
  }

  function test_xReceive_ShouldUpdatePongs(bytes32 transferId, uint256 amount, uint32 domain, uint256 pings) public {
    uint256 pongs = 0;
    ping.xReceive(transferId, amount, address(token), pong, domain, abi.encode(pings));
    assertEq(ping.pongs(), pongs + 1);
  }
}
