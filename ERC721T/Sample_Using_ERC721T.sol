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

    function Burn(uint256 _tokenId) public {
        _burn(_tokenId);
    }

}
