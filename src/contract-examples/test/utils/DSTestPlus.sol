// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XConsole} from "./Console.sol";

import {ERC20} from "@solmate/tokens/ERC20.sol";

import {Vm} from "@std/Vm.sol";
import {Test} from "forge-std/Test.sol";

contract DSTestPlus is Test {
  XConsole console = new XConsole();

  // Domain IDs for testnet
  uint32 public goerliDomainId = 1735353714;
  uint32 public optimismGoerliDomainId = 1735356532;

  // Chain IDs
  uint32 public goerliChainId = 5;
  uint32 public optimismGoerliChainId = 420;
}
