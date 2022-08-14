// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//MUST IMPLEMENT
import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";

//OPTIONAL IMPLEMENT
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";

contract ERC721T is IERC165, IERC721, IERC721Metadata {

    //
    mapping(bytes4 => bool) internal supportedInterfaces; //supportedInterfaces[bytes] = bool;

    //
    mapping(address => uint256) private _balances; //balances[address] = uint256;
    mapping(uint256 => address) private _tokenOwner; //_tokenOwner[uint256] = address;

    //
    mapping(uint256 => address) private _tokenApprovedAddress; //_tokenApprovedAddress[uint256] = address;
    mapping(address => mapping(address => bool)) private _operatorApproved; //_operatorApproved[address][address] = bool;

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    //
    string private _name;
    string private _symbol;
    string private _baseURI;

    uint256 private _totalSupply;

    address private _deployer;

/* ************************************************************************************************************************ */
/* ************************************************************************************************************************ */
    //THE BLUEPRINT IDEA FOR SAVING EACH TOKEN STRING ACHIEVEMENT DATA by Tony Ma

    //each tokenId has multiples achievement and each of them could be different.
    //therefore, it needs an independent counter for counting the achievement number to avoid over write the achievement.

    mapping(uint256 => mapping(uint256 => string)) private _tokenAchievements; //_tokenAchievements[_tokenId][achievementId] = achievementString;
    mapping(uint256 => uint256) private _tokenAchievementCounter; //_tokenAchievementCounter[_tokenId] = countNum;


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

/* ************************************************************************************************************************ */

    constructor(string memory name_, string memory symbol_, string memory baseURI_) {
        //supportedInterface -> ERC165, ERC721
        supportedInterfaces[0x01ffc9a7] = true; // ERC165
        supportedInterfaces[0x80ac58cd] = true; // ERC721

        //token name
        _name=name_;
        _symbol=symbol_;
        _baseURI=baseURI_;

        //nft data
        _totalSupply=0;

        //deployerAddress
        _deployer = msg.sender;
    }

/* ************************************************************************************************************************ */

    //IERC165 MUST Methods
    function supportsInterface(bytes4 interfaceID) public view virtual override returns (bool) {
        return supportedInterfaces[interfaceID];
    }

/* ************************************************************************************************************************ */

    //ERC721 MUST Methods
    //Methods-getting contract data
    function balanceOf(address _owner) public view virtual override returns (uint256) {
        require(_owner!=address(0),"INVALID-ZERO-ADDRESS"); //ensure the address != address(0)

        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view virtual override returns (address) {
        require(istokenExist(_tokenId),"INVALID-TOKEN-NOT-EXIST"); //ensure the token has minted/owned

        return _tokenOwner[_tokenId];
    }

    //Methods-handling approval
    //_token & approvedAddress
    function approve(address _approved, uint256 _tokenId) public virtual override payable {
        require(msg.sender==ownerOf(_tokenId) || isApprovedForAll(ownerOf(_tokenId), msg.sender), "INVALID-APPROVE");

        _tokenApprovedAddress[_tokenId] = _approved; //update

        emit Approval(ownerOf(_tokenId), _approved, _tokenId); //event
    }

    function getApproved(uint256 _tokenId) public view virtual override returns (address) {
        require(istokenExist(_tokenId), "INVALID-TOKEN-NOT-EXIST");

        return _tokenApprovedAddress[_tokenId];
    }
    //_owner & _operator
    function setApprovalForAll(address _operator, bool _approved) public virtual override {
        address _owner = msg.sender;
        _operatorApproved[_owner][_operator] = _approved; //update

        emit ApprovalForAll(_owner, _operator, _approved); //event
    }

    function isApprovedForAll(address _owner, address _operator) public view virtual override returns (bool) {
        return _operatorApproved[_owner][_operator];
    }

    //Methods-executing transactions
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public virtual override payable {
        require(msg.sender==ownerOf(_tokenId) || isApprovedForAll(ownerOf(_tokenId), msg.sender) || getApproved(_tokenId)==msg.sender, "INVALID-SAFE-TRANSFER-FROM");
        require(ownerOf(_tokenId)==_from, "INVALID-NOT-OWNER");
        require(_to!=address(0), "INVALID-ZERO-ADDRESS");
        require(istokenExist(_tokenId), "INVALID-TOKEN-NOT-EXIST");

        _transfer(_from, _to, _tokenId);

        require(_checkOnERC721Received(_from, _to, _tokenId, data), "NOT_ABLE_TO_RECEIVE_NFT");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public virtual override payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public virtual override payable {
        require(msg.sender==ownerOf(_tokenId) || isApprovedForAll(ownerOf(_tokenId), msg.sender) || getApproved(_tokenId)==msg.sender, "INVALID-TRANSFER-FROM");
        require(ownerOf(_tokenId)==_from, "INVALID-NOT-OWNER");
        require(_to!=address(0), "INVALID-ZERO-ADDRESS");
        require(istokenExist(_tokenId), "INVALID-TOKEN-NOT-EXIST");

        _transfer(_from, _to, _tokenId);
    }

/* ************************************************************************************************************************ */

    //USEFUL Methods
    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        require(ownerOf(_tokenId)==_from, "INVALID-NOT-OWNER");
        require(_to!=address(0), "INVALID-ZERO-ADDRESS");

        delete _tokenApprovedAddress[_tokenId]; //rest the approved address of the token

        _tokenOwner[_tokenId]=_to; //update new token owner
        _balances[_from]--; //update sender balance
        _balances[_to]++; //update receiver balance

        emit Transfer(_from, _to, _tokenId);
    }

    //very useful code from this website
    //https://ethereum.stackexchange.com/questions/15641/how-does-a-contract-find-out-if-another-address-is-a-contract
    function isContract(address _addr) internal view returns (bool){
        uint32 size;
        assembly {  size := extcodesize(_addr)  }

        return (size > 0); //check _to is a smart contract (code size > 0).
    }

    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data) private returns (bool output) {
        //very useful code from eip721 suggested contract example
        //https://github.com/nibbstack/erc721/blob/master/src/contracts/tokens/nf-token.sol#L161
        output = false;
        if (isContract(_to)) {//check it is a contract
            bytes4 retval = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(retval == MAGIC_ON_ERC721_RECEIVED);
            output=true;
        } else output=true;
    }

    function istokenExist(uint256 _tokenId) internal view returns (bool result) {
        if (_tokenOwner[_tokenId]!=address(0)) result=true; //ownerAddress!=address(0) = someone has minted/owned
        else result = false;
        return result;
    }

    //very useful code from openzeppelin
    //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol
    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

/* ************************************************************************************************************************ */

    //ERC721 OPTIONAL Metadata
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(istokenExist(_tokenId), "INVALID-TOKEN-NOT-EXIST");
        //string memory baseURI = _baseURI();
        return bytes(baseURI()).length > 0 ? string(abi.encodePacked(baseURI(), toString(_tokenId))) : "";
    }

    function baseURI() internal view virtual returns (string memory) {
        return _baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public {
        _baseURI = _newBaseURI;
    }

/* ************************************************************************************************************************ */

    //ERC721 OPTIONAL Enumerable
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

/* ************************************************************************************************************************ */

    //ERC721 safeMint flow - using the safeTransferFrom flow
    function _safeMint(address _to, uint256 _tokenId) internal {
        _safeMint(_to, _tokenId, "");
    }

    function _safeMint(address _to, uint256 _tokenId, bytes memory data) internal {
        _mint(_to, _tokenId);
        require(_checkOnERC721Received(address(0), _to, _tokenId, data), "NOT_ABLE_TO_RECEIVE_NFT");
    }

    function _mint(address _to, uint256 _tokenId) internal {
        require(_to!=address(0), "INVALID-ZERO-ADDRESS");
        require(!istokenExist(_tokenId), "INVALID-TOKEN-HAS-BEEN-MINTED");

        _tokenOwner[_tokenId]=_to;
        _balances[_to]++;
        _totalSupply++;

        emit Transfer(address(0), _to, _tokenId);
    }

/* ************************************************************************************************************************ */

    //ERC721 burn
    function _burn(uint256 _tokenId) internal {
        address owner = ownerOf(_tokenId);

        // Clear approvals
        delete _tokenApprovedAddress[_tokenId];

        _balances[owner] -= 1;
        delete _tokenOwner[_tokenId];

        emit Transfer(owner, address(0), _tokenId);
    }

/* ************************************************************************************************************************ */

    modifier onlyDeployer {
        require(msg.sender == _deployer, "INVALID-NOT-DEPLOYER");
        _;
    }

}
