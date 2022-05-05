// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainPermissioned} from "../../permissioned/XDomainPermissioned.sol";
import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";
import {ConnextHandler} from "nxtp/nomad-xapps/contracts/connext/ConnextHandler.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title XDomainPermissionedTestUnit
 * @notice Unit tests for XDomainPermissioned.
 */
contract XDomainPermissionedTestUnit is DSTestPlus {
  MockERC20 private token;
  IConnextHandler private connext;
  XDomainPermissioned private xPermissioned;
  address private target = address(1);

  event UpdateInitiated(address asset, uint256 amount, address onBehalfOf);

  function setUp() public {
    connext = new ConnextHandler();
    token = new MockERC20("TestToken", "TT", 18);
    xPermissioned = new XDomainPermissioned(IConnextHandler(connext));

    vm.label(address(this), "TestContract");
    vm.label(address(connext), "Connext");
    vm.label(address(token), "TestToken");
    vm.label(address(xPermissioned), "XDomainPermissioned");
  }

  function testUpdateEmitsUpdateInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    uint256 newValue = 100;

    // Mock the xcall
    bytes memory mockxcall = abi.encodeWithSelector(connext.xcall.selector);
    vm.mockCall(address(connext), mockxcall, abi.encode(1));

    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit UpdateInitiated(address(token), newValue, address(userChainA));

    vm.prank(address(userChainA));
    xPermissioned.update(
      target,
      address(token),
      rinkebyChainId,
      kovanChainId,
      newValue
    );
  }
}

/**
 * @title XDomainPermissionedTestForked
 * @notice Integration tests for XDomainPermissioned. Should be run with forked testnet (Kovan).
 */
contract XDomainPermissionedTestForked is DSTestPlus {
  // Testnet Addresses
  address private connext = 0xA09C4Dd04fd656d2ED0ee1c95A1cB14B921296A8;
  address private testToken = 0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F;
  address private target = address(1);

  XDomainPermissioned private xPermissioned;
  MockERC20 private token;

  event UpdateInitiated(address asset, uint256 amount, address onBehalfOf);

  function setUp() public {
    xPermissioned = new XDomainPermissioned(IConnextHandler(connext));
    token = MockERC20(0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F);

    vm.label(connext, "Connext");
    vm.label(address(xPermissioned), "XDomainPermissioned");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testUpdateEmitsUpdateInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    uint256 newValue = 100;

    vm.expectEmit(true, true, true, true);
    emit UpdateInitiated(testToken, newValue, address(userChainA));

    vm.prank(address(userChainA));
    xPermissioned.update(
      target,
      address(token),
      rinkebyChainId,
      kovanChainId,
      newValue
    );
  }
}
