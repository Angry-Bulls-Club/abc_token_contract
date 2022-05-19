// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


// ABCToken
contract ABCToken is ERC20, Ownable {
    constructor() ERC20("Angry Bulls Club", "ABC") {
        _mint(owner(), 3e8 ether);
        adminAddress[owner()] = true;
    }
    
    mapping(address => bool) public adminAddress;
    mapping(address => uint256) public timelock;

    //event
    event LockAddress(address account, uint256 releaseTime);

    // MODIFIERS
    modifier onlyAdmin() {
            require(adminAddress[msg.sender] == true, "admin: wut?");
            _;
    }
    modifier lock() {
            require(timelock[msg.sender] <= block.timestamp, "ERC20: Locked balance");
            _;
    }
    function setAdmin(address _admin, bool approved) public onlyOwner {
        adminAddress[_admin] = approved;
    }

    /* 
    * Lock user amount.
    * @param _account account to lock
    * @param _releaseTime Time to release from lock state.
    * @param _amount  amount to lock.
    * @return Boolean
    */
    function setLock(address _account, uint256 _releaseTime) onlyAdmin public {
        require(_releaseTime > block.timestamp, "ERC20 : Current time is greater than release time");
        timelock[_account] = _releaseTime; 
        emit LockAddress( _account, _releaseTime); 
    }

    /*
    * transfer
    * @param recipient Token trasfer destination acount.
    * @param amount Token transfer amount.
    * @return Boolean 
    */ 
    function transfer(address recipient, uint256 amount) lock() public override returns (bool) {
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) lock() public override returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }
 
    // @param value Amount to decrease.
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }
    // only owner 
    function burnOwner(address burnAddress, uint256 value) onlyOwner public {
        _burn(burnAddress, value);
    }
}