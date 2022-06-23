// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import {NFTHashi} from "../../nfthashi/NFTHashi.sol";
import {IExecutor} from "nxtp/core/connext/interfaces/IExecutor.sol";
import {XCallArgs} from "nxtp/core/connext/libraries/LibConnextStorage.sol";
import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

/**
 * @title MockConnextHandler
 * @notice Unit tests MockConnextHandler Mock for NFTHashi.
 */
contract MockConnextHandler {
  IExecutor private _executor;

  function setExecutor(address executor) public {
    _executor = IExecutor(executor);
  }

  // solhint-disable-next-line no-unused-vars
  function xcall(XCallArgs memory xCallArgs) public payable returns (bytes32) {
    return "";
  }

  function executor() public view returns (IExecutor) {
    return _executor;
  }
}

/**
 * @title MockExecutor
 * @notice Unit tests Executor Mock for NFTHashi.
 */

contract MockExecutor {
  address private _originSender;
  uint32 private _origin;

  function setOriginSender(address originSender_) public {
    _originSender = originSender_;
  }

  function setOrigin(uint32 origin_) public {
    _origin = origin_;
  }

  function execute(address to, bytes memory data) public {
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory log) = to.call(data);
    require(success, string(log));
  }

  function originSender() public view returns (address) {
    return _originSender;
  }

  function origin() public view returns (uint32) {
    return _origin;
  }
}

/**
 * @title NFTHashiTestUnit
 * @notice Unit tests for NFTHashi.
 */
contract NFTHashiTestUnit is DSTestPlus {
  MockERC20 private token;
  MockConnextHandler private connext;
  MockExecutor private executor;
  NFTHashi private nftHashi;

  function setUp() public {
    executor = new MockExecutor();
    connext = new MockConnextHandler();
    connext.setExecutor(address(executor));

    token = new MockERC20("TestToken", "TT", 18);
    nftHashi = new NFTHashi(
      rinkebyDomainId,
      address(connext),
      address(token),
      "",
      "",
      0,
      0,
      "http://localhost:3000/metadata/"
    );

    vm.label(address(connext), "ConnextHandler");
    vm.label(address(token), "TestToken");
    vm.label(address(nftHashi), "NFTHashi");
    vm.label(address(this), "TestContract");
  }

  function testXSend() public {
    address userChainA = address(0xA);
    address userChainB = address(0xB);
    address rinkebyNFTHashi = address(0xC);
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");
    vm.label(address(rinkebyNFTHashi), "rinkebyNFTHashi");

    nftHashi.setBridgeContract(rinkebyDomainId, rinkebyNFTHashi);
    console.log("bridge contract set");

    uint256 tokenId = 0;

    nftHashi.mint(address(userChainA));
    console.log(
      "userChainA NFT balance",
      nftHashi.balanceOf(address(userChainA))
    );

    vm.prank(address(userChainA));
    nftHashi.xSend(
      address(userChainA),
      address(userChainB),
      tokenId,
      rinkebyDomainId
    );
  }

  function testXReceive() public {
    address userChainA = address(0xA);
    address userChainB = address(0xB);
    address rinkebyNFTHashi = address(0xC);
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");
    vm.label(address(rinkebyNFTHashi), "rinkebyNFTHashi");

    nftHashi.setBridgeContract(rinkebyDomainId, rinkebyNFTHashi);
    console.log("bridge contract set");

    uint256 tokenId = 0;
    bytes memory data = abi.encodeWithSignature(
      "xReceive(address,uint256)",
      address(userChainB),
      tokenId
    );
    executor.execute(address(nftHashi), data);
    console.log(
      "userChainB NFT balance",
      nftHashi.balanceOf(address(userChainB))
    );
  }
}

/**
 * @title NFTHashiTestForked
 * @notice Integration tests for NFTHashi. Should be run with forked testnet (Kovan).
 */
contract NFTHashiTestForked is DSTestPlus {
  address public connext = 0x3366A61A701FA84A86448225471Ec53c5c4ad49f;
  address public constant testToken =
    0x3FFc03F05D1869f493c7dbf913E636C6280e0ff9;

  NFTHashi private nftHashi;

  function setUp() public {
    nftHashi = new NFTHashi(
      kovanDomainId,
      connext,
      testToken,
      "",
      "",
      0,
      0,
      "http://localhost:3000/metadata/"
    );

    vm.label(connext, "ConnextHandler");
    vm.label(testToken, "TestToken");
    vm.label(address(nftHashi), "NFTHashi");
    vm.label(address(this), "TestContract");
  }

  function testXSend() public {
    address userChainA = address(0xA);
    address userChainB = address(0xB);
    address rinkebyNFTHashi = address(0xC);
    vm.label(address(userChainA), "userChainA");
    vm.label(address(userChainB), "userChainB");
    vm.label(address(rinkebyNFTHashi), "rinkebyNFTHashi");

    nftHashi.setBridgeContract(rinkebyDomainId, rinkebyNFTHashi);
    console.log("bridge contract set");

    uint256 tokenId = 0;

    nftHashi.mint(address(userChainA));
    console.log(
      "userChainA NFT balance",
      nftHashi.balanceOf(address(userChainA))
    );

    vm.prank(address(userChainA));
    nftHashi.xSend(
      address(userChainA),
      address(userChainB),
      tokenId,
      rinkebyDomainId
    );
  }
}
