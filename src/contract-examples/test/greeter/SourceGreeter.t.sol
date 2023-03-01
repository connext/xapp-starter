// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {TestHelper} from "../utils/TestHelper.sol";
import {ForkTestHelper} from "../utils/ForkTestHelper.sol";
import {SourceGreeter} from "../../greeter/SourceGreeter.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SourceGreeterTestUnit
 * @notice Unit tests for SourceGreeter.
 */
contract SourceGreeterTestUnit is TestHelper {
  SourceGreeter public source;
  address public target = address(bytes20(keccak256("Mock DestinationGreeter")));
  bytes32 public transferId = keccak256("12345");
  uint256 public relayerFee = 1e16;
  uint256 public slippage;

  function setUp() public override {
    super.setUp();
    
    source = new SourceGreeter(MOCK_CONNEXT, MOCK_ERC20);
    slippage = source.slippage();

    vm.label(address(source), "SourceGreeter");
    vm.label(target, "Mock DestinationGreeter");
  }

  function test_SourceGreeter__updateGreeting_shouldWork(
    uint256 amount,
    string memory newGreeting
  ) public {
    amount = bound(amount, 0, 1e36);
    bytes memory callData = abi.encode(newGreeting);

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
          target,
          MOCK_ERC20,
          USER_CHAIN_A,
          amount,
          slippage,
          callData
        )
      ),
      abi.encode(transferId)
    );

    // Test that MOCK_ERC20s are sent from USER_CHAIN_A to SourceGreeter contract
    vm.expectCall(
      MOCK_ERC20, 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          USER_CHAIN_A, 
          address(source),
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
          target,
          MOCK_ERC20,
          USER_CHAIN_A,
          amount,
          slippage,
          callData
        )
      )
    );

    source.xUpdateGreeting{value: relayerFee}(
      target,
      OPTIMISM_GOERLI_DOMAIN_ID,
      newGreeting,
      amount,
      relayerFee
    );

    vm.stopPrank();
  }
}

/**
 * @title SourceGreeterTestForked
 * @notice Integration tests for SourceGreeter. Should be run with forked testnet (Goerli).
 */
contract SourceGreeterTestForked is ForkTestHelper {
  SourceGreeter public source;
  address public target = address(bytes20(keccak256("Mock DestinationGreeter")));
  uint256 public relayerFee = 1e16;
  uint256 public slippage = 10000;

  function setUp() public override {
    super.setUp();
    
    source = new SourceGreeter(address(CONNEXT_GOERLI), address(TEST_ERC20_GOERLI));

    vm.label(address(source), "SourceGreeter");
    vm.label(target, "Mock DestinationGreeter");
  }

  function test_SourceGreeter__updateGreeting_shouldWork(
    uint256 amount,
    string memory newGreeting
  ) public {
    amount = bound(amount, 0, 1e36);
    bytes memory callData = abi.encode(newGreeting);

    // Deal USER_CHAIN_A some native tokens to cover relayerFee
    vm.deal(USER_CHAIN_A, relayerFee);

    // Mint USER_CHAIN_A some TEST
    TEST_ERC20_GOERLI.mint(USER_CHAIN_A, amount);

    vm.startPrank(USER_CHAIN_A);

    TEST_ERC20_GOERLI.approve(address(source), amount);

    // Test that tokens are sent from USER_CHAIN_A to SourceGreeter contract
    vm.expectCall(
      address(TEST_ERC20_GOERLI), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          USER_CHAIN_A, 
          address(source),
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
          target,
          address(TEST_ERC20_GOERLI),
          USER_CHAIN_A,
          amount,
          slippage,
          callData
        )
      )
    );

    source.xUpdateGreeting{value: relayerFee}(
      target,
      OPTIMISM_GOERLI_DOMAIN_ID,
      newGreeting,
      amount,
      relayerFee
    );

    vm.stopPrank();
  }
}
