// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import '../Context.sol';
import '../Libraries.sol';
import '../IBEP20.sol';

contract BasePool is Operator {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 public mineToken;

    uint256 public DURATION = 5 days;
    uint256 public starttime = 1614614400;
    uint256 public periodFinish = 0;

    bool private open = true;

    modifier needStart() {
        require(block.timestamp >= starttime, 'AcceleratorCashPool: not start');
        require(open, 'Pool must open');
        _;
    }

    function changeMineToken(address token) external onlyOperator {
        mineToken = IBEP20(token);
    }

    function changeOpenStatus(bool _open) external onlyOperator {
        open = _open;
    }

    function setTimeCircle(uint256 starttime_, uint256 day)
        public
        virtual
        onlyOperator
    {
        starttime = starttime_;
        DURATION = day * 1 days;
        periodFinish = starttime.add(DURATION);
    }

    function transferReward(uint256 amount, address receiver) internal {
        mineToken.safeTransfer(receiver, amount);
    }

    function paybackMineToken() public onlyOperator {
        mineToken.transfer(msg.sender, mineToken.balanceOf(address(this)));
    }
}

contract TokenPool is BasePool {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 public stakeToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakeToken.safeTransfer(msg.sender, amount);
    }

    function changeStakeToken(address token) external onlyOperator {
        stakeToken = IBEP20(token);
    }
}

contract ETHPool is BasePool {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake() public payable virtual {
        uint256 amount = msg.value;
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        //transfer
        address(uint160(msg.sender)).transfer(amount);
    }
}
