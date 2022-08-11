// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20T.sol";

contract ERC20T is IERC20T {
    uint256 private _totalSupply;
    uint256 private _burnCounter;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    string private _name;
    string private _symbol;
    address private _ownerAddress;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _ownerAddress = msg.sender;
    }

    //Methods
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view virtual override returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public virtual override returns (bool success) {
        //requirements
        require(_to != msg.sender); //the sender cannot transfer to himselves.
        require(_value <= balances[msg.sender]); //the value should not be larger than the sender balances.

        //updates
        balances[msg.sender] -= _value; //update the sender balances.
        balances[_to] += _value; //update the receiver balances.

        //actions
        emit Transfer(msg.sender, _to, _value); //call the transfer event.

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool success) {
        //requirements
        require(_to != _from); //the sender cannot transfer to himselves.
        require(_value <= balances[_from]); //the value should not be larger than the sender balances.
        require(_value <= allowed[_from][msg.sender]); //the value should be allowed by the sender.

        //updates
        balances[_from] -= _value; //update the sender balances.
        allowed[_from][msg.sender] -= _value; //update the allowed value.
        balances[_to] += _value; //update the receiver balances.

        //actions
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool success) {
        //updates
        allowed[msg.sender][_spender] = _value; //save the allowed value.

        //actions
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public virtual override view returns (uint256 remaining) {
        return allowed[_owner][_spender]; //return the allowed value.
    }

    //Other methods
    function ownerAddress() public virtual view returns (address) {
        return _ownerAddress;
    }

    function _mint(address _to, uint256 _amount) internal virtual {
        //requirements
        require (_amount != 0, "MINT-AMOUNT-SHOULD-BE-LARGER-THAN-ZERO");

        //updates
        _totalSupply += _amount; //update the _totalSupply.
        balances[_to] += _amount; //update the minter balances.
    }

    function _burn(address _to, uint256 _amount) internal virtual {
        //requirements
        require (_amount != 0, "MINT-AMOUNT-SHOULD-BE-LARGER-THAN-ZERO");

        //updates
        _burnCounter += _amount; //update the _burnCounter.
        balances[_to] -= _amount; //update the minter balances.
    }

    function burnToken() public view virtual returns (uint256) {
        return _burnCounter;
    }

    //Modifiers
    modifier onlyOwner {
        require(msg.sender == _ownerAddress, "NOT-OWNER"); //check the sender is the owner or not.
        _;
    }

}
