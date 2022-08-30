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
  address public connext = 	0xB4C1340434920d70aD774309C75f9a4B679d801e;
  address public promiseRouter = 	0xD25575eD38fa0F168c9Ba4E61d887B6b3433F350;
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
    source.xChainUpdate(
      target,
      goerliDomainId,
      optimismGoerliDomainId,
      newValue,
      authenticated
    );
  }
}
