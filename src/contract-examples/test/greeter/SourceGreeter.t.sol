// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {TestHelper} from "../utils/TestHelper.sol";
import {ForkTestHelper} from "../utils/ForkTestHelper.sol";
import {SourceGreeter} from "../../greeter/SourceGreeter.sol";
import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SourceGreeterTestUnit
 * @notice Unit tests for SourceGreeter.
 */
contract SourceGreeterTestUnit is TestHelper {
  SourceGreeter public source;
  address public target = address(bytes20(keccak256("target")));
  uint256 public cost;
  uint256 public relayerFee = 1e16;
  uint256 public slippage = 10000;

  function setUp() public override {
    super.setUp();
    
    source = new SourceGreeter(IConnext(MOCK_CONNEXT), IERC20(MOCK_ERC20));
    cost = source.cost();

    vm.label(address(source), "SourceGreeter");
    vm.label(target, "Mock DestinationGreeter");
  }

  function test_SourceGreeter__updateGreeting_shouldWork(string memory newGreeting) public {
    bytes memory callData = abi.encode(newGreeting);

    // Give USER_CHAIN_A native gas to cover relayerFee
    vm.deal(USER_CHAIN_A, relayerFee);

    vm.startPrank(USER_CHAIN_A);

    // Mock all calls to ERC20
    vm.mockCall(MOCK_ERC20, abi.encodeWithSelector(IERC20.allowance.selector), abi.encode(cost));
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
          cost,
          slippage,
          callData
        )
      ),
      abi.encode()
    );

    // Test that MOCK_ERC20s are sent from USER_CHAIN_A to SourceGreeter contract
    vm.expectCall(
      MOCK_ERC20, 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          USER_CHAIN_A, 
          address(source),
          cost
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
          cost,
          slippage,
          callData
        )
      )
    );

    source.updateGreeting{value: relayerFee}(
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
contract SourceGreeterTestForked is ForkTestHelper {
  SourceGreeter public source;
  address public target = address(bytes20(keccak256("Mock DestinationGreeter")));
  uint256 public relayerFee = 1e16;
  uint256 public slippage = 10000;
  uint256 public cost;

  function setUp() public override {
    super.setUp();
    
    source = new SourceGreeter(IConnext(CONNEXT_GOERLI), IERC20(TEST_ERC20_GOERLI));
    cost = source.cost();

    vm.label(address(source), "SourceGreeter");
    vm.label(target, "Mock DestinationGreeter");
  }

  function test_SourceGreeter__updateGreeting_shouldWork(string memory newGreeting) public {
    bytes memory callData = abi.encode(newGreeting);

    // Deal USER_CHAIN_A some native tokens to cover relayerFee
    vm.deal(USER_CHAIN_A, relayerFee);

    // Mint USER_CHAIN_A some TEST
    TEST_ERC20_GOERLI.mint(USER_CHAIN_A, cost);

    vm.startPrank(USER_CHAIN_A);

    TEST_ERC20_GOERLI.approve(address(source), cost);

    // Test that tokens are sent from USER_CHAIN_A to SourceGreeter contract
    vm.expectCall(
      address(TEST_ERC20_GOERLI), 
      abi.encodeCall(
        IERC20.transferFrom, 
        (
          USER_CHAIN_A, 
          address(source),
          cost
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
          cost,
          slippage,
          callData
        )
      )
    );

    source.updateGreeting{value: relayerFee}(
      target,
      OPTIMISM_GOERLI_DOMAIN_ID,
      newGreeting,
      slippage,
      relayerFee
    );

    vm.stopPrank();
  }
}
