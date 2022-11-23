//SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MonthlySubscription is Ownable, ERC721Enumerable {
  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private supply;

  string expiredUri;
  string baseURI;

  uint256 public cost = 0 ether;
  uint subStart;
  
  constructor() ERC721("Monthly Subscription", "SUB") {
    setBaseURI("https://pub-gmn.com/GMNV2/subscribed.json");
    setExpiredURI("https://pub-gmn.com/GMNV2/expired.json");
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
    
  // public

  function mint() public payable {
    if (msg.sender != owner()) {
    require(msg.value >= cost);
    }
    subStart = block.timestamp;
    _mintLoop(msg.sender, subStart);
    }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "Token Already Minted");

    bool subscribed = true;

    if (block.timestamp > tokenId + 2629743) { // 2629743
      subscribed = false;
      return expiredUri;
    }
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI))
        : "";
  }

      function _mintLoop(address _receiver, uint256) internal {
        for (uint256 i = 0; i < 1; i++) {
        supply.increment();
        subStart = block.timestamp;
        _safeMint(_receiver, subStart);
    }
  }

// public functions

  function totalSupply() public view override  returns (uint256) {
    return supply.current();
  }

  function subCheck(uint tokenId) public view returns(string memory Holder) {
  bool subscribed = false;
  if (block.timestamp > tokenId + 2629743) {  // 1 Month in seconds 2629743
    subscribed = false;
    return("Not Subscribed");
  } else {
    subscribed = true;
    return("Subscribed");
  }
}

  function daysLeft(uint256 tokenId) public pure returns(uint256 _daysLeft) {
    _daysLeft = (tokenId - 2629743);
}

  //only owner

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setExpiredURI(string memory _newExpiredURI) public onlyOwner {
    expiredUri = _newExpiredURI;
  }

  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}