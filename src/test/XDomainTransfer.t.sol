// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainTransfer} from "../XDomainTransfer.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {Connext} from "nxtp/Connext.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {TestERC20} from "./TestERC20.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";
import "@std/stdlib.sol";

contract XDomainTransferTest is DSTestPlus {
  using stdStorage for StdStorage;
  StdStorage public stdstore;

  event TransferInitiated(address asset, address from, address to);

  XDomainTransfer private xTransfer;
  Connext private connext;
  TestERC20 private token;

  // Nomad Domain IDs
  uint32 private mainnetDomainId = 6648936;
  uint32 private rinkebyDomainId = 2000;
  uint32 private kovanDomainId = 3000;

  // Connext helper functions
  function setApprovedRouter(address _router, bool _approved) internal {
    uint256 writeVal = _approved ? 1 : 0;
    stdstore
      .target(address(connext))
      .sig(connext.approvedRouters.selector)
      .with_key(_router)
      .checked_write(writeVal);
  }

  function setApprovedAsset(address _asset, bool _approved) internal {
    uint256 writeVal = _approved ? 1 : 0;
    stdstore
      .target(address(connext))
      .sig(connext.approvedAssets.selector)
      .with_key(_asset)
      .checked_write(writeVal);
  }

  function setUp() public {
    token = new TestERC20();
    connext = new Connext();
    xTransfer = new XDomainTransfer(IConnext(address(connext)));

    // Connext setup
    address bridgeRouter = address(1);
    address tokenRegistry = address(2);
    address wrapper = address(3);

    connext.initialize(
      mainnetDomainId,
      payable(bridgeRouter),
      tokenRegistry,
      wrapper
    );
    setApprovedRouter(bridgeRouter, true);
    setApprovedAsset(address(token), true);
    console.log(
      "Token approved on Connext",
      connext.approvedAssets(bytes32(uint256(uint160(address(token)))))
    );

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
