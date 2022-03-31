// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainTransfer} from "../XDomainTransfer.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {Connext} from "nxtp/Connext.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {TestERC20} from "./TestERC20.sol";
import {ConnextFixture} from "./utils/ConnextFixture.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";
import "@std/stdlib.sol";

contract XDomainTransferTest is ConnextFixture, DSTestPlus {
  XDomainTransfer private xTransfer;
  TestERC20 private token;

  event TransferInitiated(address asset, address from, address to);

  function setUp() public {
    // Set up Connext fixture
    address bridgeRouter = address(1);
    address tokenRegistry = address(2);
    address wrapper = address(3);
    super.setUp(bridgeRouter, tokenRegistry, wrapper);

    setApprovedRouter(bridgeRouter, true);
    token = new TestERC20();
    setApprovedAsset(address(token), true);
    console.log(
      "Token approved on Connext",
      connext.approvedAssets(bytes32(uint256(uint160(address(token)))))
    );

    xTransfer = new XDomainTransfer(IConnext(address(connext)));
    vm.label(address(connext), "Connext");
    vm.label(address(xTransfer), "XDomainTransfer");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testTransferInitiated() public {
    ERC20User userChainA = new ERC20User(token);
    ERC20User userChainB = new ERC20User(token);
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");

    token.mint(address(userChainA), 10_000);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    userChainA.approve(address(this), 10_000);

    vm.expectEmit(true, true, true, true);
    emit TransferInitiated(address(token), address(this), address(userChainB));

    startHoax(address(userChainA));
    xTransfer.transfer(
      address(userChainB),
      address(token),
      kovanDomainId,
      rinkebyDomainId,
      10_000
    );
    vm.stopPrank();
  }
}
