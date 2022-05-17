// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {Transfer} from "../../transfer/Transfer.sol";
import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";
import {ConnextHandler} from "nxtp/nomad-xapps/contracts/connext/ConnextHandler.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title TransferTestUnit
 * @notice Unit tests for Transfer.
 */
contract TransferTestUnit is DSTestPlus {
  MockERC20 private token;
  IConnextHandler private connext;
  Transfer private transfer;

  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    connext = new ConnextHandler();
    token = new MockERC20("TestToken", "TT", 18);
    transfer = new Transfer(IConnextHandler(connext));

    vm.label(address(connext), "Connext");
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
    bytes memory mockxcall = abi.encodeWithSelector(connext.xcall.selector);
    vm.mockCall(address(connext), mockxcall, abi.encode(1));

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
      kovanDomainId,
      rinkebyDomainId,
      amount
    );
  }
}

/**
 * @title TransferTestForked
 * @notice Integration tests for Transfer. Should be run with forked testnet (Kovan).
 */
contract TransferTestForked is DSTestPlus {
  // Testnet Addresses
  address public connext = 0x71a52104739064bc35bED4Fc3ba8D9Fb2a84767f;
  address public constant testToken =
    0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F;

  Transfer private transfer;
  MockERC20 private token;

  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    transfer = new Transfer(IConnextHandler(connext));
    token = MockERC20(0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F);

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
      kovanDomainId,
      rinkebyDomainId,
      amount
    );
  }
}
