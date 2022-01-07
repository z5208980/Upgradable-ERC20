//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Initialisable.sol";
import "./SafeMath.sol";
import "./Proxy.sol";

// Loosely based of OpenZep ERC20
contract ERC20V2 is Initialisable {
    using SafeMath for uint256;

    string public name; 
    string public symbol;
    uint8 public decimals;
    uint256 public supply;

    uint256 public ethBalance; // smart contract eth balance
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    event Transfer(address sender, address recipient, uint256 tokens);
    event Approval(address sender, address spender, uint256 tokens);

    function initialise(string memory _name, string memory _symbol, uint8 _decimals, uint256 _supply) virtual public payable initialiser {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        supply = _supply;
        ethBalance = 0;
        balances[msg.sender] = supply;
    }
    
    function totalSupply() external view returns(uint256) {
        return supply;
    } 

    function balanceOf(address account) external view returns(uint) {
        return balances[account];
    } 

    function transfer(address recipient, uint amount) external  returns(bool) {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(msg.sender,recipient,amount);
        return true;
    } 

    function allowance(address owner, address spender) external view returns(uint) {
        return allowed[owner][spender];
    }  

    function approve(address spender, uint amount) external returns(bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender,spender,amount);
        return true;
    }

    function transferFrom(address owner, address recipient, uint amount) external returns(bool) {
        require(balances[owner] >= amount);
        require(allowed[owner][msg.sender] >= amount);
        balances[owner] = balances[owner].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(owner, recipient, amount);
        return true;
    }

    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // Anyone can send ETH to this smart contract to mint same amount of ERC20 tokens
    function mint() public payable returns(bool) {
        require(msg.value > 0, "ERC20: Requires 1 or more wei");
        ethBalance = ethBalance.add(msg.value);
        supply = supply.add(msg.value);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        return true;
    }

    // Upgrade the smart contract to add a feature that allow user to burn ERC20 token and get 90% of the ETH back
    function burn(address payable account, uint256 amount) public payable returns(bool) {
        require(msg.sender == account, "ERC20: Can only burn your tokens");
        require(balances[account] >= amount);
        supply = supply.sub(amount);
        balances[account] = balances[account].sub(amount);
        account.transfer(amount.mul(90).div(100));
        emit Transfer(account, address(0), amount);
        return true;
    }
}
