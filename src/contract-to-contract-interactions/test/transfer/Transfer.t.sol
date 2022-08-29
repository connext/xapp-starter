// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import {Transfer} from "../../transfer/Transfer.sol";
import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title TransferTestUnit
 * @notice Unit tests for Transfer.
 */
contract TransferTestUnit is DSTestPlus {
  MockERC20 private token;
  address private connext;
  Transfer private transfer;

  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    connext = address(1);
    token = new MockERC20("TestToken", "TT", 18);
    transfer = new Transfer(IConnextHandler(connext));

    vm.label(connext, "ConnextHandler");
    vm.label(address(transfer), "Transfer");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testTransferEmitsTransferInitiated() public {
    address userChainA = address(0xA);
    address userChainB = address(0xB);
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");

    // TODO: fuzz this
    uint256 amount = 10_000;

    // Grant the user some tokens
    token.mint(address(userChainA), amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    // User must approve transfer to transfer contract
    vm.prank(userChainA);
    token.approve(address(transfer), amount);

    // Mock the xcall
    bytes memory mockxcall = abi.encodeWithSelector(
      IConnextHandler.xcall.selector
    );
    vm.mockCall(connext, mockxcall, abi.encode(1));

    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit TransferInitiated(
      address(token),
      address(userChainA),
      address(userChainB)
    );

    vm.prank(address(userChainA));
    transfer.transfer(
      address(userChainB),
      address(token),
      goerliDomainId,
      optimismGoerliDomainId,
      amount
    );
  }
}

/**
 * @title TransferTestForked
 * @notice Integration tests for Transfer. Should be run with forked testnet (Goerli).
 */
contract TransferTestForked is DSTestPlus {
  // Testnet Addresses
  address public connext = 0xB4C1340434920d70aD774309C75f9a4B679d801e;
  address public constant testToken = 0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1;

  Transfer private transfer;
  MockERC20 private token;

  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    transfer = new Transfer(IConnextHandler(connext));
    token = MockERC20(testToken);

    vm.label(connext, "Connext");
    vm.label(address(transfer), "Transfer");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testTransferEmitsTransferInitiated() public {
    address userChainA = address(0xA);
    address userChainB = address(0xB);
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");

    // TODO: fuzz this
    uint256 amount = 10_000;

    // Grant the user some tokens
    token.mint(address(userChainA), amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    // User must approve transfer to transfer
    vm.prank(userChainA);
    token.approve(address(transfer), amount);

    vm.expectEmit(true, true, true, true);
    emit TransferInitiated(
      address(token),
      address(userChainA),
      address(userChainB)
    );

    vm.prank(address(userChainA));
    transfer.transfer(
      address(userChainB),
      address(token),
      goerliDomainId,
      optimismGoerliDomainId,
      amount
    );
  }
}
