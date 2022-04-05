// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainPermissionless} from "../XDomainPermissionless.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {Connext} from "nxtp/Connext.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title XDomainPermissionlessTestUnit
 * @notice Unit tests for XDomainPermissionless.
 */
contract XDomainPermissionlessTestUnit is DSTestPlus {
  MockERC20 private token;
  IConnext private connext;
  XDomainPermissionless private xPermissionless;
  address private target = address(1);

  event DepositInitiated(address asset, uint256 amount, address onBehalfOf);

  function setUp() public {
    connext = new Connext();
    token = new MockERC20("TestToken", "TT", 18);
    xPermissionless = new XDomainPermissionless(IConnext(connext));

    vm.label(address(this), "TestContract");
    vm.label(address(connext), "Connext");
    vm.label(address(token), "TestToken");
    vm.label(address(xPermissionless), "XDomainPermissionless");
  }

  function testDepositEmitsDepositInitiated() public {
    ERC20User userChainA = new ERC20User(token);
    vm.label(address(userChainA), "userChainA");

    // TODO: fuzz this
    uint256 amount = 10_000;

    // Grant the user some tokens
    token.mint(address(userChainA), amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    // User must approve transfer to xPermissionless
    userChainA.approve(address(xPermissionless), amount);

    // Mock the xcall
    bytes memory mockxcall = abi.encodeWithSelector(connext.xcall.selector);
    vm.mockCall(address(connext), mockxcall, abi.encode(1));
    
    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit DepositInitiated(address(token), amount, address(userChainA));

    vm.prank(address(userChainA));
    xPermissionless.deposit(
      target,
      address(token),
      rinkebyChainId,
      kovanChainId,
      10_000
    );
  }
}

/**
 * @title XDomainPermissionlessTestForked
 * @notice Integration tests for XDomainPermissionless. Should be run with forked testnet (Kovan).
 */
contract XDomainPermissionlessTestForked is DSTestPlus {
  // Testnet Addresses
  address private connext = 0xA09C4Dd04fd656d2ED0ee1c95A1cB14B921296A8;
  address private testToken = 0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F;
  address private target = address(1);

  XDomainPermissionless private xPermissionless;
  MockERC20 private token;

  event PermissionlessInitiated(address asset, uint256 amount, address onBehalfOf);

  function setUp() public {
    xPermissionless = new XDomainPermissionless(IConnext(connext));
    token = MockERC20(0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F);

    vm.label(connext, "Connext");
    vm.label(address(xPermissionless), "XDomainPermissionless");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testDepositEmitsPermissionlessInitiated() public {
    ERC20User userChainA = new ERC20User(token);
    vm.label(address(userChainA), "userChainA");

    // TODO: fuzz this
    uint256 amount = 10_000;

    // Grant the user some tokens
    token.mint(address(userChainA), amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    // User must approve transfer to xPermissionless 
    userChainA.approve(address(xPermissionless), amount);

    vm.expectEmit(true, true, true, true);
    emit PermissionlessInitiated(testToken, amount, address(userChainA));

    vm.prank(address(userChainA));
    xPermissionless.deposit(
      target,
      address(token),
      rinkebyChainId,
      kovanChainId,
      10_000
    );
  }
}
