// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainUnpermissioned} from "../../unpermissioned/XDomainUnpermissioned.sol";
import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";
import {ConnextHandler} from "nxtp/nomad-xapps/contracts/connext/ConnextHandler.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title XDomainUnpermissionedTestUnit
 * @notice Unit tests for XDomainUnpermissioned.
 */
contract XDomainUnpermissionedTestUnit is DSTestPlus {
  MockERC20 private token;
  IConnextHandler private connext;
  XDomainUnpermissioned private xUnpermissioned;
  address private target = address(1);

  event DepositInitiated(address asset, uint256 amount, address onBehalfOf);

  function setUp() public {
    connext = new ConnextHandler();
    token = new MockERC20("TestToken", "TT", 18);
    xUnpermissioned = new XDomainUnpermissioned(IConnextHandler(connext));

    vm.label(address(this), "TestContract");
    vm.label(address(connext), "Connext");
    vm.label(address(token), "TestToken");
    vm.label(address(xUnpermissioned), "XDomainUnpermissioned");
  }

  function testDepositEmitsDepositInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    // TODO: fuzz this
    uint256 amount = 10_000;

    // Grant the user some tokens
    token.mint(address(userChainA), amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    // User must approve transfer to xUnpermissioned
    vm.prank(userChainA);
    token.approve(address(xUnpermissioned), amount);

    // Mock the xcall
    bytes memory mockxcall = abi.encodeWithSelector(connext.xcall.selector);
    vm.mockCall(address(connext), mockxcall, abi.encode(1));

    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit DepositInitiated(address(token), amount, address(userChainA));

    vm.prank(address(userChainA));
    xUnpermissioned.deposit(
      target,
      address(token),
      rinkebyChainId,
      kovanChainId,
      10_000
    );
  }
}

/**
 * @title XDomainUnpermissionedTestForked
 * @notice Integration tests for XDomainUnpermissioned. Should be run with forked testnet (Kovan).
 */
contract XDomainUnpermissionedTestForked is DSTestPlus {
  // Testnet Addresses
  address private connext = 0xA09C4Dd04fd656d2ED0ee1c95A1cB14B921296A8;
  address private testToken = 0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F;
  address private target = address(1);

  XDomainUnpermissioned private xUnpermissioned;
  MockERC20 private token;

  event UnpermissionedInitiated(
    address asset,
    uint256 amount,
    address onBehalfOf
  );

  function setUp() public {
    xUnpermissioned = new XDomainUnpermissioned(IConnextHandler(connext));
    token = MockERC20(0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F);

    vm.label(connext, "Connext");
    vm.label(address(xUnpermissioned), "XDomainUnpermissioned");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testDepositEmitsUnpermissionedInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    // TODO: fuzz this
    uint256 amount = 10_000;

    // Grant the user some tokens
    token.mint(address(userChainA), amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    // User must approve transfer to xUnpermissioned
    vm.prank(userChainA);
    token.approve(address(xUnpermissioned), amount);

    vm.expectEmit(true, true, true, true);
    emit UnpermissionedInitiated(testToken, amount, address(userChainA));

    vm.prank(address(userChainA));
    xUnpermissioned.deposit(
      target,
      address(token),
      rinkebyChainId,
      kovanChainId,
      10_000
    );
  }
}
