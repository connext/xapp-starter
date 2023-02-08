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
  ERC20PresetMinterPauser public token = new ERC20PresetMinterPauser("TestToken", "TEST");
  IConnext public connext = IConnext(address(0xC));
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    bridge = new SimpleBridge(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(bridge), "SimpleBridge");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_transferShouldTransferFromCaller(uint256 amount) public {
    uint256 relayerFee = 1e16;
    uint256 slippage = 10000;
    bytes memory callData = abi.encode("");

    // Deal userChainA some native tokens to cover relayerFee
    vm.deal(userChainA, relayerFee);

    // Mint userChainA some TEST
    token.mint(userChainA, amount);

    vm.startPrank(userChainA);

    // userChainA must approve the amount to SimpleBridge contract
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

    // Test that xcall is called
    vm.expectCall(
      address(connext), 
      relayerFee,
      abi.encodeCall(
        IConnext.xcall, 
        (
          OPTIMISM_GOERLI_DOMAIN_ID,
          userChainB,
          address(token),
          userChainB,
          amount,
          slippage,
          callData
        )
      )
    );

    bridge.transfer{value: relayerFee}(
      address(token),
      amount,
      userChainB,
      OPTIMISM_GOERLI_DOMAIN_ID,
      slippage,
      relayerFee
    );

    vm.stopPrank();
  }
}

/**
 * @title SimpleBridgeTestForked
 * @notice Integration tests for SimpleBridge. Should be run with forked testnet.
 */
contract SimpleBridgeTestForked is DSTestPlus {
  // Testnet addresses on Goerli
  IConnext public connext = IConnext(0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649);
  ERC20PresetMinterPauser public token = ERC20PresetMinterPauser(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);

  SimpleBridge private bridge;
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    bridge = new SimpleBridge(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(bridge), "SimpleBridge");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_transferShouldWork(uint256 amount) public {
    uint256 relayerFee = 1e16;
    uint256 slippage = 10000;
    bytes memory callData = abi.encode("");
    
    // Deal userChainA some native tokens to cover relayerFee
    vm.deal(userChainA, relayerFee);

    // Mint userChainA some TEST
    token.mint(userChainA, amount);

    vm.startPrank(userChainA);

    // userChainA must approve the amount to SimpleBridge
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
      relayerFee,
      abi.encodeCall(
        IConnext.xcall, 
        (
          OPTIMISM_GOERLI_DOMAIN_ID,
          userChainB,
          address(token),
          userChainB,
          amount,
          slippage,
          callData
        )
      )
    );

    bridge.transfer{value: relayerFee}(
      address(token),
      amount,
      userChainB,
      OPTIMISM_GOERLI_DOMAIN_ID,
      slippage,
      relayerFee
    );

    vm.stopPrank();
  }
}
