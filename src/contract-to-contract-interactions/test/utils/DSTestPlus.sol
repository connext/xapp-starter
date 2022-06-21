// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XConsole} from "./Console.sol";

import {ERC20} from "@solmate/tokens/ERC20.sol";

import {Vm} from "@std/Vm.sol";
import {Test} from "forge-std/Test.sol";

contract DSTestPlus is Test {
  XConsole console = new XConsole();

  // Nomad Domain IDs
  uint32 public mainnetDomainId = 6648936;
  uint32 public rinkebyDomainId = 1111;
  uint32 public goerliDomainId = 3331;

  // Chain IDs
  uint32 public mainnetChainId = 1;
  uint32 public ropstenChainId = 3;
  uint32 public rinkebyChainId = 4;
  uint32 public goerliChainId = 5;
}
