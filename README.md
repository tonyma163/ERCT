## ERC721T - Saving Unique NFT Data on the Smart Contract.

## ERC721 Issue
Nowadays, the ERC721 token has non-fungible. However, only the token id is unique and immutable. The ERC721 is not saving any data about the NFT (only the metadata uri). It is just a bridge linking the NFT to the JSON metadata, which truly saves the public's NFT data that the public desired (like the image :) ). Although many good NFT projects have uploaded their metadata on the IPFS (It is no doubt that it is much safe), we cannot ensure the pinning service keeps running so It still has the potential risk. Once the metadata lost, nobody will know the info in its.

## Suggestion
Blockchain is a technology that ensure the data is immutable. So, the answer is easy - saving the NFTs data on the smart contract.

## About ERC721T
ERC721T, a blueprint, allows each of the NFTs could save its achievements.

Saving data on the smart contract is great, however, the gas fee is the most important problem. Especially the NFTs on the Ethereum mainnet need to pay a heavy gas so users are not willing the write data on the smart contract often.

So maybe the ERC721T is more suitable on the cheaper gas fee chains like the polygon, fantom.

## Code
Each tokenId has multiples achievement and each of them could be different. Therefore, it needs an independent counter for counting the achievement number to avoid over write the achievement.

Data storage variables
```solidity
mapping(uint256 => mapping(uint256 => string)) private _tokenAchievements; //_tokenAchievements[_tokenId][achievementId] = achievementString;
mapping(uint256 => uint256) private _tokenAchievementCounter; //_tokenAchievementCounter[_tokenId] = countNum;
```

Data storage functions

_addAchievement: enter the token Id and the achievement string to save the achievements.

_getAchievement: enter the token Id and the archivement Id to get the specific achievement.

```solidity
function _addAchievement(uint256 _tokenId, string memory newAchievementString) internal {
        require(istokenExist(_tokenId), "INVALID-TOKEN-NOT-EXIST");
        require(bytes(newAchievementString).length!=0, "INVALID-NULL-ACHIEVEMENT");

        uint256 _achievementId = _tokenAchievementCounter[_tokenId];
        _tokenAchievements[_tokenId][_achievementId] = newAchievementString;

        _tokenAchievementCounter[_tokenId]++;
    }

    function _getAchievement(uint256 _tokenId, uint256 _achievementId) internal view returns(string memory) {
        require(istokenExist(_tokenId), "INVALID-TOKEN-NOT-EXIST");
        require(bytes(_tokenAchievements[_tokenId][_achievementId]).length!=0, "INVALID-NULL-ACHIEVEMENT");

        return _tokenAchievements[_tokenId][_achievementId];
    } 
```

## Usage
download all the solidity files in the ERC721T folder and import them

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

## References
Most of the code are from the EIP, OpenZeppelin.
https://eips.ethereum.org/EIPS/eip-165
https://eips.ethereum.org/EIPS/eip-721
https://github.com/nibbstack/erc721
https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC721
https://ethereum.stackexchange.com/questions/15641/how-does-a-contract-find-out-if-another-address-is-a-contract
