// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import {Source} from "../../with-calldata/Source.sol";
import {IConnextHandler} from "nxtp/core/connext/interfaces/IConnextHandler.sol";
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
    source = new Source(IConnextHandler(connext), promiseRouter);

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
      IConnextHandler.xcall.selector
    );
    vm.mockCall(connext, mockxcall, abi.encode(1));

    // Check for an event emitted
    vm.expectEmit(true, true, true, true);
    emit UpdateInitiated(target, newValue, authenticated);

    vm.prank(address(userChainA));
    source.updateValue(
      target,
      rinkebyChainId,
      goerliChainId,
      newValue,
      authenticated
    );
  }
}

/**
 * @title SourceTestForked
 * @notice Integration tests for Source. Should be run with forked testnet (Rinkeby).
 */
contract SourceTestForked is DSTestPlus {
  // Testnet Addresses
  address public connext = 0x4cAA6358a3d9d1906B5DABDE60A626AAfD80186F;
  address public promiseRouter = 0x6e4Eaa2A41f9c211C8511540BbB1D971B1483128;
  address private target = address(1);

  Source private source;

  event UpdateInitiated(address to, uint256 newValue, bool authenticated);

  function setUp() public {
    source = new Source(IConnextHandler(connext), promiseRouter);

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
    source.updateValue(
      target,
      rinkebyDomainId,
      goerliDomainId,
      newValue,
      authenticated
    );
  }
}
