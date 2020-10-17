// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;


/**
* @title interface of ERC 20 token
* 
*/
interface IERC20 {
    
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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
 * @title Implementation of the {IERC20} interface.
 *
 */
contract ERC20 is IERC20 {

    using SafeMath for uint256; 

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    constructor(string memory name, string  memory symbol, uint8 decimals, uint256 totalSupply){
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _mint(msg.sender, totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
       */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Warning!!!! only be used when owner address is compromised
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title TimelockerRole
 * @dev TimelockerRole can lock any users wallet for some time.
 */
contract TimelockerRole is Ownable {

    using Roles for Roles.Role;
  
    event TimelockerAdded(address indexed addedTimelocker, address indexed addedBy);
    event TimelockerRemoved(address indexed removedTimelocker, address indexed removedBy);

    Roles.Role private _timelockers;

    modifier onlyTimelocker() {
        require(isTimelocker(msg.sender), "TimelockerRole: caller does not have the Timelocker role");
        _;
    }

    function isTimelocker(address account) public view returns (bool) {
        return _timelockers.has(account);
    }

    function addTimelocker(address account) public onlyOwner {
        _addTimelocker(account);
    }

    function removeTimelocker(address account) public onlyOwner {
        _removeTimelocker(account);
    }

    function _addTimelocker(address account) internal {
        _timelockers.add(account);
        emit TimelockerAdded(account, msg.sender);
    }

    function _removeTimelocker(address account) internal {
        _timelockers.remove(account);
        emit TimelockerRemoved(account, msg.sender);
    }
}



/**
 * @title WhitelisterRole
 * @dev WhitelisterRole can whitelist any users wallet.
 */
contract WhitelisterRole is Ownable {

    using Roles for Roles.Role;
  
    event WhitelisterAdded(address indexed addedWhitelister, address indexed addedBy);
    event WhitelisterRemoved(address indexed removedWhitelister, address indexed removedBy);

    Roles.Role private _whitelisters;

    modifier onlyWhitelister() {
        require(isWhitelister(msg.sender), "WhitelisterRole: caller does not have the Whitelister role");
        _;
    }

    function isWhitelister(address account) public view returns (bool) {
        return _whitelisters.has(account);
    }

    function addWhitelister(address account) public onlyOwner {
        _addWhitelister(account);
    }

    function removeWhitelister(address account) public onlyOwner {
        _removeWhitelister(account);
    }

    function _addWhitelister(address account) internal {
        _whitelisters.add(account);
        emit WhitelisterAdded(account, msg.sender);
    }

    function _removeWhitelister(address account) internal {
        _whitelisters.remove(account);
        emit WhitelisterRemoved(account, msg.sender);
    }
}




/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 */
contract Pausable is Ownable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor (){
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

     /**
     * @dev To pause the all transfer of the token
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev To unpause the all trasfer of the token
     */
    function unpause() public onlyOwner {
        _unpause();
    }  

}

/**
 * @title Timelockable
 * @dev TimelockerRole can lock any users all fund in wallet address upto some releaseTime
 */ 

contract Timelockable is TimelockerRole{

    mapping (address => uint256) private timeLockups;

    event AccountLock(address indexed _address, uint256 _releaseTime);

    /**
    * @dev Lock the amount of this address till releaseTime
    */
    function lock( address _address, uint256 _releaseTime) public onlyTimelocker returns (bool) {
        require(_releaseTime > block.timestamp, "Timelockable: Release time should be greater than release time");
        require(_address != address(0), "Timelockable: Address should not be Zero address");
        timeLockups[_address] = _releaseTime;
        emit AccountLock(_address, _releaseTime);
        return true;
    }
    
    /**
     * @dev Get the timestamp when timelock is released
     */
    function checkLockup(address _address) public view returns(uint256) {
         return timeLockups[_address];
    }

    /**
    * @dev Check if wallet is locked or not
    */
    function isLockup(address _address) public view returns(bool) {
         return timeLockups[_address] > block.timestamp;
    }
}


/**
 * @title Whitelistable
 * @dev The Whitelistable contract has an can whitelist any address to transfer the security token
 */
contract Whitelistable is  WhitelisterRole{
    
    event SetWhitelist(address _address, bool status);

    // white list status
    mapping (address => bool) private whitelist;
    
    /**
    * @dev Set a white list address
    */
    function setWhitelist(address to, bool status)  public onlyWhitelister returns(bool){
        whitelist[to] = status;
        emit SetWhitelist(to, status);
        return true;
    }

    /**
    * @dev Get the status of the whitelist
    */
    function isWhitelisted(address _address) public view returns(bool){
        return whitelist[_address];
    }

    /**
    * @dev Determine if sender and receiver are whitelisted, return true if both accounts are whitelisted
    */
    function checkWhitelists(address from, address to) external view returns (bool) {
        return whitelist[from] && whitelist[to];
    }
}


/**
 * @title RVW 
 * @dev RVW is ERC20 standard with  Ownable, Pausable, Whitelistable, Timelockable and IERC1404
 */ 
contract RVW is ERC20, Ownable, Pausable, Whitelistable, Timelockable, IERC1404{

    /**
     * @dev name, symbol and decimals of LCX Token
     */     
    string private constant _name = 'RVW';
    string private constant _symbol = 'RVW';
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 5000000 * (10 ** 18) ;
    uint8 public constant SUCCESS = 0;
    
    /**
     *   @dev external smart contract for transfer restriction
     */
    IERC1404 private restrictedTransfer;

    event UpdatedRestrictedTransfer(address indexed _restrictedTransfer);
    
    /**
     * @dev Initializes the details of the token with all the above details
     * Also put the ERC1404 smart contract
     */
    constructor(address _restrictedTransfer)  ERC20(_name, _symbol, _decimals, _totalSupply) {
        restrictedTransfer = IERC1404(_restrictedTransfer);
    }
    
    /**
     * @dev modifier to check the transfer restriction
     */
    modifier notRestricted (address _from, address _to, uint256 _value) {
        uint8 code = restrictedTransfer.detectTransferRestriction(_from, _to, _value);
        require(code == SUCCESS, restrictedTransfer.messageForTransferRestriction(code));
        _;
    }
    
   /**
     * @dev Update ERC1404 smart contract
     */
    function updateRestrictedTransfer(address _restrictedTransfer) public onlyOwner{
        restrictedTransfer = IERC1404(_restrictedTransfer);
        emit UpdatedRestrictedTransfer(_restrictedTransfer);
    }
    
    /**
     * @dev Get the code of the transfer restriction
     */
    function detectTransferRestriction (address _from, address _to, uint256 _amount) public override view  returns (uint8) {
        require(address(restrictedTransfer) != address(0), 'RestrictedTransfer: Contract is not set');
        return restrictedTransfer.detectTransferRestriction(_from, _to, _amount);
    }
        
     /**
     * @dev Get the message of the code form the trasnfer restriction contract
     */
    function messageForTransferRestriction (uint8 code) external override view  returns (string memory) {
        return restrictedTransfer.messageForTransferRestriction(code);
    }

    /**
     * @dev Standard trasnfer function is override here with restriction
     */
    function transfer (address to, uint256 value) public override notRestricted(msg.sender, to, value) returns (bool success) {
        success = super.transfer(to, value);
    }

    /**
     * @dev Standard trasnferFrom function is override here with restriction
     */
    function transferFrom (address from, address to, uint256 value) public override notRestricted(from, to, value) returns (bool success) {
        success = super.transferFrom(from, to, value);
    }

}


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {

    struct Role {
        mapping (address => bool) manager;
    }

    /**
     * @dev Add the role to the account
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.manager[account] = true;
    }

    /**
     * @dev Remove the role of the account
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.manager[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.manager[account];
    }
}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}