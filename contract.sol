pragma solidity ^0.7.0;
// xRPTR represents staked RPTR (liquid staking), and gives exposure to staking just by holding it
// Thus, it allows doing DeFi, trades and much more while enjoying RPTR's staking APR
// As a BEP20, it is transferrable through cross-chain protocols, allowing to use it on other chains' DeFi (unleashing a full new potential)

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}

interface MasterChefInterface {
    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of RAPTORs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRaptorPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRaptorPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. RAPTORs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that RAPTOR distribution occurs.
        uint256 accRaptorPerShare; // Accumulated RAPTORs per share, times 1e12. See below.
    }

	// write functions
	function deposit(uint256 _pid, uint256 _amount) external;
	function withdraw(uint256 _pid, uint256 _amount) external;
	function emergencyWithdraw(uint256 _pid) external;
	
	// read functions
	function poolInfo(uint256 _pid) external view returns (PoolInfo calldata _i);
	function userInfo(uint256 _pid, address _user) external view returns (UserInfo calldata _u);
	function pendingCake(uint256 _pid, address _user) external view returns (uint256);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

contract xRPTR is ERC20Interface {
	using SafeMath for uint256;
	
	// ERC20
	string public name = "Staked Raptor";
	string public symbol = "xRPTR";
	uint8 public decimals = 18;
	
	mapping (address => uint256) public balanceOf;
	uint256 public totalSupply;
	mapping(address => mapping(address => uint256)) public allowances;
	
	// backend variables
	ERC20Interface public RPTR;
	MasterChefInterface public staking;
	
	// ERC20 events
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	// backing-stake events
	event StakeUnderlying(uint256 RPTRAmount);
	event UnstakeUnderlying(uint256 RPTRAmount);
	
	// token stake/redeem events
	event Stake(uint256 tokens, uint256 xAmount);
	event Redeem(uint256 tokens, uint256 xAmount);
	
	constructor(address _rptr, address _masterchef) {
		RPTR = ERC20Interface(_rptr);
		staking = MasterChefInterface(_masterchef);
	}
	
	modifier compounds {
		_;
		_compound();
	}
	
	// ERC20 backend
	function _transfer(address from, address to, uint256 tokens) private compounds {
		balanceOf[from] = balanceOf[from].sub(tokens, "INSUFFICIENT_BALANCE");
		balanceOf[to] = balanceOf[to].add(tokens);
		emit Transfer(from, to, tokens);
	}
	
	// ERC20 write functions
	function approve(address spender, uint256 tokens) public override returns (bool) {
		allowances[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}
	
	function transfer(address to, uint256 tokens) public override returns (bool) {
		_transfer(msg.sender, to, tokens);
		return true;
	}
	
	function transferFrom(address from, address to, uint256 tokens) public override returns (bool) {
		allowances[from][msg.sender] = allowances[from][msg.sender].sub(tokens, "INSUFFICIENT_ALLOWANCE");
		_transfer(from, to, tokens);
		return true;
	}
	
	// ERC20 read functions
	function allowance(address owner, address spender) public override view returns (uint256) {
		return allowances[owner][spender];
	}
	
	// collateral info
	function getStakedRPTR() public view returns (uint256) {
		return staking.userInfo(0, address(this)).amount;
	}
	
	function getSpendableRPTR() public view returns (uint256) {
		return RPTR.balanceOf(address(this));
	}
	
	function getPendingRewards() public view returns (uint256) {
		return staking.pendingCake(0, address(this));
	}
	
	function getTotalBacking() public view returns (uint256) {
		return getStakedRPTR().add(getPendingRewards()).add(getPendingRewards());
	}
	
	function notStaked() public view returns (uint256) {
		return getSpendableRPTR().add(getPendingRewards());
	}
	
	// collateral management
	function _stake(uint256 tokens) private {
		staking.deposit(0, tokens);
		emit StakeUnderlying(tokens);
	}
	
	function _unstake(uint256 tokens) private {
		staking.withdraw(0, tokens);
		emit UnstakeUnderlying(tokens);
	}
	
	function _claim() private {
		staking.deposit(0,0);
	}
	
	function _compound() private {
		_stake(notStaked()); // rewards get instantly staked without need for sketchy shit
	}
	
	// transfers management
	function ensureAvailability(uint256 tokens) {
		_claim();	// claims rewards, they now count as spendable
		uint256 avbl = getSpendableRPTR();
		if (avbl >= tokens) {
			return;	// halts execution here if there's enough tokens available, otherwise unstake missing
		}
		uint256 needed = tokens.sub(avbl);
		_unstake(needed);
	}
	
	function transferOut(uint256 tokens, address to) private {
		uint256 avbl = notStaked();
		uint256 needed = tokens > avbl ? tokens.sub(avbl) : 0;
		_unstake(needed);
		RPTR.transfer(tokens, to);
	}
	
	// backing per token management
	function getUnderlyingRPTR(uint256 xAmount) public view returns (uint256) {
		return xAmount.mul(getTotalBacking()).div(totalSupply);
	}
	
	function getXamount(uint256 rAmount) public view returns (uint256) {
		return rAmount.mul(totalSupply).div(getTotalBacking());
	}
	
	// supply management
	function _mint(address to, uint256 tokens) private {
		balanceOf[to] = balanceOf[to].add(tokens);
		totalSupply = totalSupply.add(tokens);
		emit Transfer(address(0), to, tokens);
	}
	
	function _burn(address from, uint256 tokens) private {
		balanceOf[from] = balanceOf[from].sub(tokens, "INSUFFICIENT_BALANCE");
		totalSupply = totalSupply.sub(tokens);
		emit Transfer(from, address(0), tokens);
	}
	
	// stake/redeem part
	function stake(uint256 RPTRAmount) public compounds returns (uint256 obtained) {
		uint256 xAmount = getXamount(RPTRAmount);
		RPTR.transferFrom(msg.sender, address(this), RPTRAmount);
		_mint(msg.sender, xAmount);
		emit Stake(RPTRAmount, xAmount);
		return xAmount;
	}
	
	function redeem(uint256 xAmount) public compounds returns (uint256 obtained) {
		uint256 rAmount = getUnderlyingRPTR(xAmount);
		_burn(msg.sender, xAmount);
		transferOut(msg.sender, rAmount);
		emit Redeem(rAmount, xAmount);
		return rAmount;
	}
}