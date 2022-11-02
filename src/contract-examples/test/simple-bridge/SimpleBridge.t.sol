// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {SimpleBridge} from "../../simple-bridge/SimpleBridge.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SimpleBridgeTestUnit
 * @notice Unit tests for SimpleBridge.
 */
contract SimpleBridgeTestUnit is DSTestPlus {
  SimpleBridge public bridge;
  ERC20PresetMinterPauser public token;
  IConnext public connext = IConnext(address(1));
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    token = new ERC20PresetMinterPauser("TestToken", "TEST");
    bridge = new SimpleBridge(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(bridge), "SimpleBridge");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_xTransferShouldTransferFromCaller(uint256 amount) public {
    // Mint userChainA some tokens
    token.mint(userChainA, amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(userChainA)
    );

    vm.startPrank(userChainA);

    // userChainA must approve transfer to SimpleBridge contract
    token.approve(address(bridge), amount);

    // Mock the xcall
    bytes memory xcall = abi.encodeWithSelector(
      IConnext.xcall.selector
    );
    vm.mockCall(address(connext), xcall, abi.encode(1));

    // Test that tokens are sent from userChainA to SimpleBridge contract
    vm.expectCall(
      address(token), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          userChainA, 
          address(bridge),
          amount
        )
      )
    );

    bridge.xTransfer(
      userChainB,
      OPTIMISM_GOERLI_DOMAIN_ID,
      address(token),
      amount,
      0,
      0
    );

    vm.stopPrank();
  }
}

/**
 * @title SimpleBridgeTestForked
 * @notice Integration tests for SimpleBridge. Should be run with forked testnet.
 */
contract SimpleBridgeTestForked is DSTestPlus {
  // Staging testnet addresses on Goerli
  IConnext public connext = IConnext(0x9590e2bB6a93e2a531b0269eE7396cECc3E5d6eA);
  IERC20 public token = IERC20(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);

  address public userChainA = address(0xA);
  address public userChainB = address(0xB);
  address public whaleChainA = address(0x6d2A06543D23Cc6523AE5046adD8bb60817E0a94); 

  SimpleBridge private bridge;

  function setUp() public {
    bridge = new SimpleBridge(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(bridge), "SimpleBridge");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
    vm.label(whaleChainA, "whaleChainA");
  }

  function test_xTransferShouldWork(uint256 amount) public {
    // Whale should have enough funds for this test case
    vm.assume(token.balanceOf(whaleChainA) >= amount);

    // Send userChainA some tokens
    vm.prank(whaleChainA);
    token.transfer(userChainA, amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(userChainA)
    );

    vm.startPrank(userChainA);

    // userChainA must approve transfer to SimpleBridge contract
    token.approve(address(bridge), amount);

    // Test that tokens are sent from userChainA to SimpleBridge contract
    vm.expectCall(
      address(token), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          userChainA, 
          address(bridge),
          amount
        )
      )
    );

    // Test that xcall is called
    vm.expectCall(
      address(connext), 
      abi.encodeCall(
        IConnext.xcall, 
        (
          OPTIMISM_GOERLI_DOMAIN_ID,
          userChainB,
          address(token),
          userChainB,
          amount,
          9997,
          ""
        )
      )
    );

    bridge.xTransfer(
      userChainB,
      OPTIMISM_GOERLI_DOMAIN_ID,
      address(token),
      amount,
      9997,
      0
    );

    vm.stopPrank();
  }
}
