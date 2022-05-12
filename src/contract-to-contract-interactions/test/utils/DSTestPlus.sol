// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {XConsole} from "./Console.sol";

import "@ds/test.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

import {Vm} from "@std/Vm.sol";

contract DSTestPlus is DSTest {
    XConsole console = new XConsole();

    // Nomad Domain IDs
    uint32 public mainnetDomainId = 6648936;
    uint32 public rinkebyDomainId = 1111;
    uint32 public kovanDomainId = 2221;

    // Chain IDs
    uint32 public mainnetChainId = 1;
    uint32 public ropstenChainId = 3;
    uint32 public rinkebyChainId = 4;
    uint32 public goerliChainId = 5;
    uint32 public kovanChainId = 42;

    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(HEVM_ADDRESS);
}