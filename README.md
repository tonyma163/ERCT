## ERC721T - Saving Unique NFT Data on the Smart Contract.

## ERC721 Issue
Nowadays, the ERC721 token has non-fungible. However, only the token id is unique and immutable. The ERC721 is not saving any data about the NFT. It is just a bridge linking the NFT to the JSON metadata, which truly saves the public's NFT data that the public desired (including the image :) ). Although many good NFT projects have put the metadata on the IPFS (It is no doubt that it is much safe), we cannot ensure the pinning service keeps running so It still has the potential risk. Once the metadata lost, nobody will know the info in its.

## Suggestion
Blockchain is a technology that ensure the data is immutable. So, the answer is easy - saving the NFTs data on the smart contract.

## About ERC721T
ERC721T, a blueprint, allows each NFT could save its achievements.

## Usage
download all the solidity files and import them

```solidity

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721T.sol";

contract SampleContract is ERC721T {

    //local variables
    uint256 public maxSupply;
    uint256 public supplyCounter;

    constructor() ERC721T("Name","Symbol","URI"){
        maxSupply=3;
        supplyCounter=0;
    }

    function Mint() public onlyDeployer {
        require(totalSupply()<maxSupply, "OUT-OF-STOCKS");
        _safeMint(msg.sender, supplyCounter);
        supplyCounter++;
    }

    function addTokenAchievement(uint256 _tokenId, string memory newAchievementString) public {
        _addAchievement(_tokenId, newAchievementString);
    }

    function getTokenAchievement(uint256 _tokenId, uint256 _achievementId) public view returns(string memory) {
        return _getAchievement(_tokenId, _achievementId);
    }

```
