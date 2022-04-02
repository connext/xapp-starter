// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainTransfer} from "../../XDomainTransfer.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";
import {ConnextFixture} from "../utils/ConnextFixture.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";

contract XDomainTransferTest is ConnextFixture {
  XDomainTransfer private xTransfer;
  MockERC20 private token;
  ERC20User private userChainA;
  ERC20User private userChainB;

  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    // Set up Connext fixture
    address bridgeRouter = address(1);
    address tokenRegistry = address(2);
    address wrapper = address(3);
    super.setUp(bridgeRouter, tokenRegistry, wrapper);

    // Set up Connext internal mappings
    token = new MockERC20("TestToken", "TT", 18);
    setApprovedAsset(address(token), true);
    setAdoptedToCanonicalMapping(3000, address(token)); // TODO: this doesn't work still
    setApprovedRouter(bridgeRouter, true);

    xTransfer = new XDomainTransfer(IConnext(connext));
    userChainA = new ERC20User(token);
    userChainB = new ERC20User(token);

    vm.label(address(this), "TestContract");
    vm.label(address(connext), "Connext");
    vm.label(address(token), "TestToken");
    vm.label(address(xTransfer), "XDomainTransfer");
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");
  }

  function test_transferUserApproved() public {
    vm.expectRevert("User must approve amount");

    vm.prank(address(userChainA));
    xTransfer.transfer(
      address(userChainB),
      address(token),
      kovanDomainId,
      rinkebyDomainId,
      10_000
    );
  }

  function test_transferEmitsTransferInitiated() public {
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
