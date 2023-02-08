// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {SourceGreeter} from "../../greeter/SourceGreeter.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SourceGreeterTestUnit
 * @notice Unit tests for SourceGreeter.
 */
contract SourceGreeterTestUnit is DSTestPlus {
  SourceGreeter public source;
  ERC20PresetMinterPauser public token = new ERC20PresetMinterPauser("TestToken", "TEST");
  IConnext public connext = IConnext(address(0xC));
  address private target = address(0xD);
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    source = new SourceGreeter(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(source), "SourceGreeter");
    vm.label(address(token), "TestToken");
    vm.label(target, "DestinationGreeter");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_updateGreetingShouldWork(string memory newGreeting) public {
    uint256 relayerFee = 1e16;
    uint256 slippage = 10000;
    uint256 cost = source.cost();
    bytes memory callData = abi.encode(newGreeting);

    // Deal userChainA some native tokens to cover relayerFee
    vm.deal(userChainA, relayerFee);

    // Mint userChainA some TEST
    token.mint(userChainA, cost);

    vm.startPrank(userChainA);

    // userChainA must approve the amount to SourceGreeter
    token.approve(address(source), cost);

    // Mock the xcall
    bytes memory xcall = abi.encodeWithSelector(
      IConnext.xcall.selector
    );
    vm.mockCall(address(connext), xcall, abi.encode(1));

    // Test that tokens are sent from userChainA to SourceGreeter contract
    vm.expectCall(
      address(token), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          userChainA, 
          address(source),
          cost
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
          target,
          address(token),
          userChainA,
          cost,
          slippage,
          callData
        )
      )
    );

    source.updateGreeting{value: relayerFee}(
      address(token),
      target,
      OPTIMISM_GOERLI_DOMAIN_ID,
      newGreeting,
      slippage,
      relayerFee
    );

    vm.stopPrank();
  }
}

/**
 * @title SourceGreeterTestForked
 * @notice Integration tests for SourceGreeter. Should be run with forked testnet (Goerli).
 */
contract SourceGreeterTestForked is DSTestPlus {
  // Testnet addresses on Goerli
  IConnext public connext = IConnext(0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649);
  ERC20PresetMinterPauser public token = ERC20PresetMinterPauser(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);

  SourceGreeter public source;
  address public target = address(0xD);
  address public userChainA = address(0xA);
  address public userChainB = address(0xB);

  function setUp() public {
    source = new SourceGreeter(connext);

    vm.label(address(connext), "Connext");
    vm.label(address(source), "SourceGreeter");
    vm.label(address(token), "TestToken");
    vm.label(target, "DestinationGreeter");
    vm.label(address(this), "TestContract");
    vm.label(userChainA, "userChainA");
    vm.label(userChainB, "userChainB");
  }

  function test_updateGreetingShouldWork(string memory newGreeting) public {
    uint256 relayerFee = 1e16;
    uint256 slippage = 10000;
    uint256 cost = source.cost();
    bytes memory callData = abi.encode(newGreeting);

    // Deal userChainA some native tokens to cover relayerFee
    vm.deal(userChainA, relayerFee);

    // Mint userChainA some TEST
    token.mint(userChainA, cost);

    vm.startPrank(userChainA);

    // userChainA must approve the amount to SourceGreeter
    token.approve(address(source), cost);

    // Test that tokens are sent from userChainA to SourceGreeter contract
    vm.expectCall(
      address(token), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          userChainA, 
          address(source),
          cost
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
          target,
          address(token),
          userChainA,
          cost,
          slippage,
          callData
        )
      )
    );

    source.updateGreeting{value: relayerFee}(
      address(token),
      target,
      OPTIMISM_GOERLI_DOMAIN_ID,
      newGreeting,
      slippage,
      relayerFee
    );

    vm.stopPrank();
  }
}
