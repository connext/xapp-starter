// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import "@nfthashi/contracts/NativeHashi721.sol";

contract NFTHashi is NativeHashi721 {
  uint256 private immutable _startTokenId;
  uint256 private immutable _endTokenId;
  uint256 private _supplied;

  string private _baseTokenURI;

  constructor(
    uint32 selfDomain,
    address connext,
    address dummyTransactingAssetId,
    string memory name,
    string memory symbol,
    uint256 startTokenId,
    uint256 endTokenId,
    string memory baseTokenURI
  ) NativeHashi721(selfDomain, connext, dummyTransactingAssetId, name, symbol) {
    _startTokenId = startTokenId;
    _endTokenId = endTokenId;
    _baseTokenURI = baseTokenURI;
  }

  function mint(address to) public {
    uint256 tokenId = _startTokenId + _supplied;
    require(tokenId <= _endTokenId, "NativeHashi721: mint finished");
    _mint(to, tokenId);
    _supplied++;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }
}
