// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Source} from "../../with-calldata/Source.sol";
import {IConnext} from "@nxtp/core/connext/interfaces/IConnext.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title SourceTestUnit
 * @notice Unit tests for Source.
 */
contract SourceTestUnit is DSTestPlus {
  address private connext;
  address private promiseRouter;
  Source private source;
  address private target = address(1);

  event UpdateInitiated(address to, uint256 newValue, bool authenticated);

  function setUp() public {
    connext = address(1);
    promiseRouter = address(2);
    source = new Source(IConnext(connext), promiseRouter);

    vm.label(address(this), "TestContract");
    vm.label(connext, "Connext");
    vm.label(address(source), "Source");
  }

  function testUpdateEmitsUpdateInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    uint256 newValue = 100;
    bool authenticated = false;

    // Mock the xcall
    bytes memory mockxcall = abi.encodeWithSelector(
      IConnext.xcall.selector
    );
    vm.mockCall(connext, mockxcall, abi.encode(1));

    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit UpdateInitiated(target, newValue, authenticated);

    vm.prank(address(userChainA));
    source.xChainUpdate(
      target,
      goerliDomainId,
      optimismGoerliDomainId,
      newValue,
      authenticated
    );
  }
}

/**
 * @title SourceTestForked
 * @notice Integration tests for Source. Should be run with forked testnet (Goerli).
 */
contract SourceTestForked is DSTestPlus {
  // Testnet Addresses
  address public connext = 0xD9e8b18Db316d7736A3d0386C59CA3332810df3B;
  address public promiseRouter = 0x570faC55A96bDEA6DE85632e4b2c7Fde4efFAD55;
  address private target = address(1);

  Source private source;

  event UpdateInitiated(address to, uint256 newValue, bool authenticated);

  function setUp() public {
    source = new Source(IConnext(connext), promiseRouter);

    vm.label(connext, "Connext");
    vm.label(address(source), "Source");
    vm.label(address(this), "TestContract");
  }

  function testUpdateEmitsUpdateInitiated() public {
    address userChainA = address(0xA);
    vm.label(address(userChainA), "userChainA");

    uint256 newValue = 100;
    bool authenticated = false;

    vm.expectEmit(true, true, true, true);
    emit UpdateInitiated(target, newValue, authenticated);

    vm.prank(address(userChainA));
    source.xChainUpdate(
      target,
      goerliDomainId,
      optimismGoerliDomainId,
      newValue,
      authenticated
    );
  }
}
