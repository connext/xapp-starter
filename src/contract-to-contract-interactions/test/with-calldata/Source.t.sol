// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {Source} from "../../with-calldata/Source.sol";
import {IConnextHandler} from "nxtp/interfaces/IConnextHandler.sol";
import {ConnextHandler} from "nxtp/nomad-xapps/contracts/connext/ConnextHandler.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title SourceTestUnit 
 * @notice Unit tests for Source.
 */
contract SourceTestUnit is DSTestPlus {
  MockERC20 private token;
  IConnextHandler private connext;
  Source private source;
  address private target = address(1);

  event UpdateInitiated(address to, uint256 newValue, bool permissioned);

  function setUp() public {
    connext = new ConnextHandler();
    token = new MockERC20("TestToken", "TT", 18);
    source = new Source(IConnextHandler(connext));

    vm.label(address(this), "TestContract");
    vm.label(address(connext), "Connext");
    vm.label(address(token), "TestToken");
    vm.label(address(source), "Source");
  }

  function testUpdateEmitsUpdateInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    uint256 newValue = 100;
    bool permissioned = false;

    // Mock the xcall
    bytes memory mockxcall = abi.encodeWithSelector(connext.xcall.selector);
    vm.mockCall(address(connext), mockxcall, abi.encode(1));

    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit UpdateInitiated(target, newValue, permissioned);

    vm.prank(address(userChainA));
    source.updateValue(
      target,
      address(token),
      rinkebyChainId,
      kovanChainId,
      newValue,
      permissioned
    );
  }
}

/**
 * @title SourceTestForked
 * @notice Integration tests for Source. Should be run with forked testnet (Kovan).
 */
contract SourceTestForked is DSTestPlus {
  // Testnet Addresses
  address public connext = 0x71a52104739064bc35bED4Fc3ba8D9Fb2a84767f;
  address public constant testToken =
    0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F;
  address private target = address(1);

  Source private source;
  MockERC20 private token;

  event UpdateInitiated(address to, uint256 newValue, bool permissioned);

  function setUp() public {
    source = new Source(IConnextHandler(connext));
    token = MockERC20(0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F);

    vm.label(connext, "Connext");
    vm.label(address(source), "Source");
    vm.label(address(token), "TestToken");
    vm.label(address(this), "TestContract");
  }

  function testUpdateEmitsUpdateInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    uint256 newValue = 100;
    bool permissioned = false;

    vm.expectEmit(true, true, true, true);
    emit UpdateInitiated(target, newValue, permissioned);

    vm.prank(address(userChainA));
    source.updateValue(
      target,
      address(token),
      kovanDomainId,
      rinkebyDomainId,
      newValue,
      permissioned
    );
  }
}
