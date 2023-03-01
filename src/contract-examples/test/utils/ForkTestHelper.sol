// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Test.sol";
import {TestHelper} from "./TestHelper.sol";
import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20PresetMinterPauser} from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract ForkTestHelper is TestHelper {
  /// Testnet Addresses
  IConnext public CONNEXT_GOERLI = IConnext(0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649);
  IConnext public CONNEXT_OPTIMISM_GOERLI = IConnext(0x5Ea1bb242326044699C3d81341c5f535d5Af1504);
  IConnext public CONNEXT_MUMBAI = IConnext(0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a);
  IConnext public CONNEXT_ARBITRUM_GOERLI = IConnext(0x2075c9E31f973bb53CAE5BAC36a8eeB4B082ADC2);

  ERC20PresetMinterPauser public TEST_ERC20_GOERLI = ERC20PresetMinterPauser(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);
  ERC20PresetMinterPauser public TEST_ERC20_OPTIMISM_GOERLI = ERC20PresetMinterPauser(0x68Db1c8d85C09d546097C65ec7DCBFF4D6497CbF);
  ERC20PresetMinterPauser public TEST_ERC20_MUMBAI = ERC20PresetMinterPauser(0xeDb95D8037f769B72AAab41deeC92903A98C9E16);
  ERC20PresetMinterPauser public TEST_ERC20_ARBITRUM_GOERLI = ERC20PresetMinterPauser(0xDC805eAaaBd6F68904cA706C221c72F8a8a68F9f);

  // Fork IDs
  uint256 public goerliFork;
  uint256 public optimismGoerliFork;

  function setUp() public virtual override {
    super.setUp();

    goerliFork = vm.createFork(vm.envString("GOERLI_RPC_URL"));
    optimismGoerliFork = vm.createFork(vm.envString("OPTIMISM_GOERLI_RPC_URL"));
    
    vm.label(address(CONNEXT_GOERLI), "Connext (Goerli)");
    vm.label(address(CONNEXT_OPTIMISM_GOERLI), "Connext (Optimism-Goerli)");
    vm.label(address(CONNEXT_MUMBAI), "Connext (Mumbai)");
    vm.label(address(CONNEXT_ARBITRUM_GOERLI), "Connext (Arbitrum-Goerli)");

    vm.label(address(TEST_ERC20_GOERLI), "Test ERC20 (Goerli)");
    vm.label(address(TEST_ERC20_OPTIMISM_GOERLI), "Test ERC20 (Optimism-Goerli)");
    vm.label(address(TEST_ERC20_MUMBAI), "Test ERC20 (Mumbai)");
    vm.label(address(TEST_ERC20_ARBITRUM_GOERLI), "Test ERC20 (Arbitrum-Goerli)");
  }
}
