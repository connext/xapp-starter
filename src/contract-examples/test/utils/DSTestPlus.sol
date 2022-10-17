// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XConsole} from "./Console.sol";

import {Vm} from "@std/Vm.sol";
import {Test} from "forge-std/Test.sol";

contract DSTestPlus is Test {
  XConsole console = new XConsole();

  // Domain IDs for testnet
  uint32 public goerliDomainId = 1735353714;
  uint32 public optimismGoerliDomainId = 1735356532;
  uint32 public polygonMumbaiDomainId = 9991;
  uint32 public arbitrumGoerliDomainId = 1734439522;

  // Chain IDs
  uint32 public goerliChainId = 5;
  uint32 public optimismGoerliChainId = 420;
  uint32 public mumbaiChainId = 80001;
  uint32 public arbitrumGoerliChainId = 421613;
}
