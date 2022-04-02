// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {DSTestPlus} from "./DSTestPlus.sol";
import {Connext} from "nxtp/Connext.sol";
import "@std/stdlib.sol";

contract ConnextFixture is DSTestPlus {
  using stdStorage for StdStorage;
  StdStorage public stdstore;
  Connext public connext;

  // Nomad Domain IDs
  uint32 public mainnetDomainId = 6648936;
  uint32 public rinkebyDomainId = 2000;
  uint32 public kovanDomainId = 3000;

  function setApprovedRouter(address _router, bool _approved) internal {
    uint256 writeVal = _approved ? 1 : 0;
    stdstore
      .target(address(connext))
      .sig(connext.approvedRouters.selector)
      .with_key(_router)
      .checked_write(writeVal);
  }

  function setApprovedAsset(address _asset, bool _approved) internal {
    uint256 writeVal = _approved ? 1 : 0;
    stdstore
      .target(address(connext))
      .sig(connext.approvedAssets.selector)
      .with_key(_asset)
      .checked_write(writeVal);
  }

  function setAdoptedToCanonicalMapping(uint32 domain, address _asset) internal {
    stdstore
      .target(address(connext))
      .sig(connext.adoptedToCanonical.selector)
      .with_key(_asset)
      .depth(0)
      .checked_write(domain);
    stdstore
      .target(address(connext))
      .sig(connext.adoptedToCanonical.selector)
      .with_key(_asset)
      .depth(1)
      .checked_write(bytes32(uint256(uint160(address(_asset)))));
  }

  function setUp(address bridgeRouter, address tokenRegistry, address wrapper) public {
    connext = new Connext();

    connext.initialize(
      mainnetDomainId,
      payable(bridgeRouter),
      tokenRegistry,
      wrapper
    );
  }
}
