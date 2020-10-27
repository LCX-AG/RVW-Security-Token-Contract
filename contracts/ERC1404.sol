// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

/**
 * @title IERC1404 - Simple Restricted Token Standard 
 * @dev https://github.com/ethereum/eips/issues/1404
 */
interface IERC1404 {
    // Implementation of all the restriction of transfer and returns error code
    function detectTransferRestriction (address from, address to, uint256 value) external view returns (uint8);
    // Returns error message off error code
    function messageForTransferRestriction (uint8 restrictionCode) external view returns (string memory);
}
    
    
/**
 * @title IERC1404Checks 
 * @dev Interface for all the checks for Restricted Transfer Contract 
 */
interface IERC1404Checks {
    // Check if the transfer is paused or not.
    function paused () external view returns (bool);
    // Check if sender and receiver waller is whitelisted
    function checkWhitelists (address from, address to) external view returns (bool);
    // Check if the sender wallet is locked
    function isLockup (address _address) external view returns (bool);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    // Return the address of the owner.
    function owner() public view returns (address) {
        return _owner;
    }

    // Throws if called by any account other than the owner
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    // True if `msg.sender` is the owner of the contract.
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    // Allows the current owner to relinquish control of the contract.
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Allows the current owner to transfer control of the contract to a newOwner.
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
   
    // Transfers control of the contract to a newOwner.
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title RestrictedMessages
 * @dev All the messages and code of transfer restriction
 */ 
contract RestrictedMessages {
    
    uint8 public constant SUCCESS = 0;
    uint8 public constant PAUSED_FAILURE = 1;
    uint8 public constant WHITELIST_FAILURE = 2;
    uint8 public constant TIMELOCK_FAILURE = 3;
    
    string public constant SUCCESS_MSG = "SUCCESS";
    string public constant PAUSED_FAILURE_MSG = "ERROR: All transfer is paused now";
    string public constant WHITELIST_FAILURE_MSG = "ERROR: Wallet is not whitelisted";
    string public constant TIMELOCK_FAILURE_MSG = "ERROR: Wallet is locked";
    string public constant UNKNOWN = "ERROR: Unknown";
}


/**
 * @title ERC1404
 * @dev Simple Restricted Token Standard  
 */ 
contract ERC1404 is IERC1404, RestrictedMessages, Ownable {
    
    // Checkers contract address, basically RVW token contract address
    IERC1404Checks public checker;

    event UpdatedChecker(address indexed _checker);
    
    // Update the token contract address
    function updateChecker(address _checker) public onlyOwner{
        require(_checker != address(0), "ERC1404: Address should not be zero.");
        checker = IERC1404Checks(_checker);
        emit UpdatedChecker(_checker);
    }
    
    // All checks of transfer function
    // If contract paused, sender wallet locked and wallet not whitelisted then return error code else success
    // Note, Now there is no use of amount for restriction, but might be in the future
    function detectTransferRestriction (address from, address to, uint256 amount) public override view returns (uint8) {
        if(checker.paused()){ 
            return PAUSED_FAILURE; 
        }
        if(!checker.checkWhitelists(from, to)){ 
            return WHITELIST_FAILURE;
        }
        if(checker.isLockup(from)){ 
            return TIMELOCK_FAILURE;
        }
        return SUCCESS;
    }
    
    // Return the error message of error code
    function messageForTransferRestriction (uint8 code) public override pure returns (string memory){
        if (code == SUCCESS) {
            return SUCCESS_MSG;
        }
        if (code == PAUSED_FAILURE) {
            return PAUSED_FAILURE_MSG;
        }
        if (code == WHITELIST_FAILURE) {
            return WHITELIST_FAILURE_MSG;
        }
        if (code == TIMELOCK_FAILURE) {
            return TIMELOCK_FAILURE_MSG;
        }
        return UNKNOWN;
    }

}