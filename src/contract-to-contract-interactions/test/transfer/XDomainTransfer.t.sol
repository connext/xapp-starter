// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainTransfer} from "../../transfer/XDomainTransfer.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {Connext} from "nxtp/Connext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title XDomainTransferTestUnit
 * @notice Unit tests for XDomainTransfer.
 */
contract XDomainTransferTestUnit is DSTestPlus {
  MockERC20 private token;
  IConnext private connext;
  XDomainTransfer private xTransfer;
  
  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    connext = new Connext();
    token = new MockERC20("TestToken", "TT", 18);
    xTransfer = new XDomainTransfer(IConnext(connext));

    vm.label(address(connext), "Connext");
    vm.label(address(xTransfer), "XDomainTransfer");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testTransferEmitsTransferInitiated() public {
    ERC20User userChainA = new ERC20User(token);
    ERC20User userChainB = new ERC20User(token);
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

    // User must approve transfer to xTransfer 
    userChainA.approve(address(xTransfer), amount);

    // Mock the xcall
    bytes memory mockxcall = abi.encodeWithSelector(connext.xcall.selector);
    vm.mockCall(address(connext), mockxcall, abi.encode(1));

    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit TransferInitiated(address(token), address(userChainA), address(userChainB));

    vm.prank(address(userChainA));
    xTransfer.transfer(
      address(userChainB),
      address(token),
      kovanDomainId,
      rinkebyDomainId,
      amount
    );
  }
}

/**
 * @title XDomainTransferTestForked
 * @notice Integration tests for XDomainTransfer. Should be run with forked testnet (Kovan).
 */
contract XDomainTransferTestForked is DSTestPlus {
  // Testnet Addresses
  address private connext = 0xA09C4Dd04fd656d2ED0ee1c95A1cB14B921296A8;
  address private constant testToken = 0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F;

  XDomainTransfer private xTransfer;
  MockERC20 private token;
  
  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    xTransfer = new XDomainTransfer(IConnext(connext));
    token = MockERC20(0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F);

    vm.label(connext, "Connext");
    vm.label(address(xTransfer), "XDomainTransfer");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testTransferEmitsTransferInitiated() public {
    ERC20User userChainA = new ERC20User(token);
    ERC20User userChainB = new ERC20User(token);
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

    // User must approve transfer to xTransfer 
    userChainA.approve(address(xTransfer), amount);

    vm.expectEmit(true, true, true, true);
    emit TransferInitiated(address(token), address(userChainA), address(userChainB));

    vm.prank(address(userChainA));
    xTransfer.transfer(
      address(userChainB),
      address(token),
      kovanDomainId,
      rinkebyDomainId,
      amount
    );
  }
}
