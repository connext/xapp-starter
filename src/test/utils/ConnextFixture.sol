// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import {Connext} from "nxtp/Connext.sol";
import "@std/stdlib.sol";

contract ConnextFixture {
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