// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainPermissionless} from "../XDomainPermissionless.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title XDomainPermissionlessTest
 * @notice Tests for XDomainPermissionless. Should be run with forked testnet (Kovan).
 */
contract XDomainPermissionlessTest is DSTestPlus {
  // Nomad Domain IDs
  uint32 public mainnetDomainId = 6648936;
  uint32 public rinkebyDomainId = 2000;
  uint32 public kovanDomainId = 3000;

  // Testnet Addresses
  address private connext = 0xA09C4Dd04fd656d2ED0ee1c95A1cB14B921296A8; // kovan
  address private testToken = 0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F; // kovan
  address private targetContract = 0xd6D3D1448435777D0be05C129fB8D6411Ae0b0D7; // rinkeby

  XDomainPermissionless private xPermissionless;
  MockERC20 private constant token = MockERC20(0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F);  

  event PermissionlessInitiated(address asset, uint256 amount, address onBehalfOf);

  function setUp() public {
    xPermissionless = new XDomainPermissionless(IConnext(connext));

    vm.label(connext, "Connext");
    vm.label(address(xPermissionless), "XDomainPermissionless");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testTransferEmitsPermissionlessInitiated() public {
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
      address(targetContract),
      testToken,
      kovanDomainId,
      rinkebyDomainId,
      amount
    );
  }
}
