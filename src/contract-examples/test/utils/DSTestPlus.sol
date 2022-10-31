// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XConsole} from "./Console.sol";

import {Vm} from "@std/Vm.sol";
import {Test} from "forge-std/Test.sol";

contract DSTestPlus is Test {
  XConsole console = new XConsole();

  // Domain IDs for testnet
  uint32 public GOERLI_DOMAIN_ID = 1735353714;
  uint32 public OPTIMISM_GOERLI_DOMAIN_ID = 1735356532;
  uint32 public ARBITRUM_GOERLI_DOMAIN_ID = 1734439522;
  uint32 public POLYGON_MUMBAI_DOMAIN_ID = 9991;

  // Chain IDs
  uint32 public GOERLI_CHAIN_ID = 5;
  uint32 public OPTIMISM_GOERLI_CHAIN_ID = 420;
  uint32 public ARBITRUM_GOERLI_CHAIN_ID = 421613;
  uint32 public POLYGON_MUMBAI_CHAIN_ID = 80001;
}
