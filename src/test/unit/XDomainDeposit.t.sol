// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainDeposit} from "../../XDomainDeposit.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {ConnextFixture} from "../utils/ConnextFixture.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

contract XDomainDepositTest is ConnextFixture {
  XDomainDeposit private xDeposit;
  MockERC20 private token;
  ERC20User private userChainA;
  ERC20User private userChainB;

  event DepositInitiated(address asset, address pool, address onBehalfOf);

  // Chain IDs
  uint8 public rinkeby = 4;
  uint8 public kovan = 42;
  uint8 public polygon = 137;

  // Pool addresses
  // TODO: need to grab the right addresses, using PoolAddressesProvider.sol
  address public rinkebyDAIPool = 0x6A9865aDE2B6207dAAC49f8bCba9705dEB0B0e6D;
  address public kovanDAIPool = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
  address public polygonDAIPool = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

  uint32[] public domains = [rinkeby, kovan, polygon];
  address[] public pools = [rinkebyDAIPool, kovanDAIPool, polygonDAIPool];

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

    xDeposit = new XDomainDeposit(IConnext(connext), domains, pools);
    userChainA = new ERC20User(token);
    userChainB = new ERC20User(token);

    vm.label(address(this), "TestContract");
    vm.label(address(connext), "Connext");
    vm.label(address(token), "TestToken");
    vm.label(address(xDeposit), "XDomainDeposit");
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");
  }

  function test_depositEmitsDepositInitiated() public {
    // TODO: fuzz this
    uint256 amount = 10_000;

    // Grant the user some tokens
    token.mint(address(userChainA), amount);
    console.log(
      "userChainA TestToken balance",
      token.balanceOf(address(userChainA))
    );

    // User must approve transfer to xDeposit
    userChainA.approve(address(xDeposit), amount);

    vm.expectEmit(true, true, true, true);
    emit DepositInitiated(address(token), rinkebyDAIPool, address(userChainA));

    vm.prank(address(userChainA));
    xDeposit.deposit(address(token), 4, 42, 10_000, msg.sender);
  }
}
