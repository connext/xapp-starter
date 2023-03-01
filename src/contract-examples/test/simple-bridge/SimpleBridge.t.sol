// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {TestHelper} from "../utils/TestHelper.sol";
import {ForkTestHelper} from "../utils/ForkTestHelper.sol";
import {SimpleBridge} from "../../simple-bridge/SimpleBridge.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SimpleBridgeTestUnit
 * @notice Unit tests for SimpleBridge.
 */
contract SimpleBridgeTestUnit is TestHelper {
  SimpleBridge public bridge;
  bytes32 public transferId = keccak256("12345");
  uint256 public relayerFee = 1e16;
  uint256 public slippage = 10000;
  bytes public callData = bytes("");

  function setUp() public override {
    super.setUp();

    bridge = new SimpleBridge(MOCK_CONNEXT);

    vm.label(address(bridge), "SimpleBridge");
  }

  function test_SimpleBridge__transfer_shouldWork(uint256 amount) public {
    // Give USER_CHAIN_A native gas to cover relayerFee
    vm.deal(USER_CHAIN_A, relayerFee);

    vm.startPrank(USER_CHAIN_A);

    // Mock all calls to ERC20
    vm.mockCall(MOCK_ERC20, abi.encodeWithSelector(IERC20.allowance.selector), abi.encode(amount));
    vm.mockCall(MOCK_ERC20, abi.encodeWithSelector(IERC20.transferFrom.selector), abi.encode(true));
    vm.mockCall(MOCK_ERC20, abi.encodeWithSelector(IERC20.approve.selector), abi.encode(true));

    // Mock the xcall
    vm.mockCall(
      MOCK_CONNEXT, 
      relayerFee,
      abi.encodeCall(
        IConnext.xcall, 
        (
          OPTIMISM_GOERLI_DOMAIN_ID,
          USER_CHAIN_B,
          MOCK_ERC20,
          USER_CHAIN_A,
          amount,
          slippage,
          callData
        )
      ),
      abi.encode(transferId)
    );

    // Test that MOCK_ERC20s are sent from USER_CHAIN_A to SimpleBridge contract
    vm.expectCall(
      MOCK_ERC20, 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          USER_CHAIN_A, 
          address(bridge),
          amount
        )
      )
    );

    // Test that xcall is called
    vm.expectCall(
      MOCK_CONNEXT, 
      relayerFee,
      abi.encodeCall(
        IConnext.xcall, 
        (
          OPTIMISM_GOERLI_DOMAIN_ID,
          USER_CHAIN_B,
          MOCK_ERC20,
          USER_CHAIN_A,
          amount,
          slippage,
          callData
        )
      )
    );

    bridge.xTransfer{value: relayerFee}(
      MOCK_ERC20,
      amount,
      USER_CHAIN_B,
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
contract SimpleBridgeTestForked is ForkTestHelper {
  SimpleBridge private bridge;
  uint256 public relayerFee = 1e16;
  uint256 public slippage = 10000;
  bytes public callData = bytes("");

  function setUp() public override {
    super.setUp();

    bridge = new SimpleBridge(address(CONNEXT_GOERLI));

    vm.label(address(bridge), "SimpleBridge");
  }

  function test_SimpleBridge__transfer_shouldWork(uint256 amount) public {
    // Prevent underflow/overflow
    amount = bound(amount, 0, 1e36);
    
    // Give USER_CHAIN_A native gas to cover relayerFee
    vm.deal(USER_CHAIN_A, relayerFee);

    // Mint USER_CHAIN_A some TEST
    TEST_ERC20_GOERLI.mint(USER_CHAIN_A, amount);

    vm.startPrank(USER_CHAIN_A);

    TEST_ERC20_GOERLI.approve(address(bridge), amount);

    // Test that ERC20s are sent from USER_CHAIN_A to SimpleBridge contract
    vm.expectCall(
      address(TEST_ERC20_GOERLI), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          USER_CHAIN_A, 
          address(bridge),
          amount
        )
      )
    );

    // Test that xcall is called
    vm.expectCall(
      address(CONNEXT_GOERLI), 
      relayerFee,
      abi.encodeCall(
        IConnext.xcall, 
        (
          OPTIMISM_GOERLI_DOMAIN_ID,
          USER_CHAIN_B,
          address(TEST_ERC20_GOERLI),
          USER_CHAIN_A,
          amount,
          slippage,
          callData
        )
      )
    );

    bridge.xTransfer{value: relayerFee}(
      address(TEST_ERC20_GOERLI),
      amount,
      USER_CHAIN_B,
      OPTIMISM_GOERLI_DOMAIN_ID,
      slippage,
      relayerFee
    );

    vm.stopPrank();
  }
}
