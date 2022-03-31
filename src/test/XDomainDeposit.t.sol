// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XDomainDeposit} from "../XDomainDeposit.sol";
import {IConnext} from "nxtp/interfaces/IConnext.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";
import {ERC20User} from "@solmate/test/utils/users/ERC20User.sol";

contract XDomainDepositTest is DSTestPlus {
  XDomainDeposit private xDeposit;
  MockERC20 private token;

  event DepositInitiated(address asset, address pool, address to);

  // DAI contracts
  address public rinkebyDAI = 0x6A9865aDE2B6207dAAC49f8bCba9705dEB0B0e6D;
  address public kovanDAI = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
  address public polygonDAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

  // Aave V3 Pool contracts
  address public polygonAavePool = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;

  uint32[] public domains = [4, 42];
  address[] public pools = [rinkebyDAI, kovanDAI];

  // function setUp() public {
  //     xDeposit = new XDomainDeposit(IConnext(rinkebyConnext), domains, pools);

  //     token = new MockERC20("Token", "TKN", 18);
  // }

  // function testDepositInitiated() public {
  //     vm.expectEmit(true, true, true, true);
  //     emit DepositInitiated(address(token), rinkebyDAI, rinkebyDAI);

  //     xDeposit.deposit(address(token), 4, 42, 1000, msg.sender);
  // }
}
