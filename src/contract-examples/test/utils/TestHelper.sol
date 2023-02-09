// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@std/Test.sol";

contract TestHelper is Test {
  /// Testnet Domain IDs
  uint32 public GOERLI_DOMAIN_ID = 1735353714;
  uint32 public OPTIMISM_GOERLI_DOMAIN_ID = 1735356532;
  uint32 public ARBITRUM_GOERLI_DOMAIN_ID = 1734439522;
  uint32 public POLYGON_MUMBAI_DOMAIN_ID = 9991;

  /// Testnet Chain IDs
  uint32 public GOERLI_CHAIN_ID = 5;
  uint32 public OPTIMISM_GOERLI_CHAIN_ID = 420;
  uint32 public ARBITRUM_GOERLI_CHAIN_ID = 421613;
  uint32 public POLYGON_MUMBAI_CHAIN_ID = 80001;

  /// Mock Addresses
  address public USER_CHAIN_A = address(bytes20(keccak256("USER_CHAIN_A")));
  address public USER_CHAIN_B = address(bytes20(keccak256("USER_CHAIN_B")));
  address public MOCK_CONNEXT = address(bytes20(keccak256("MOCK_CONNEXT")));
  address public MOCK_ERC20 = address(bytes20(keccak256("MOCK_ERC20")));

  function setUp() public virtual {
    vm.label(MOCK_CONNEXT, "Mock Connext");
    vm.label(MOCK_ERC20, "Mock ERC20");
    vm.label(USER_CHAIN_A, "User Chain A");
    vm.label(USER_CHAIN_B, "User Chain B");
  }
}
