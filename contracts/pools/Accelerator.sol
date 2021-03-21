// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import '../Context.sol';
import '../Libraries.sol';
import '../IBEP20.sol';

contract Accelerator is Operator {
    using SafeMath for uint256;
    using Address for address;
    using SafeBEP20 for IBEP20;

    IBEP20 public acceleratorToken;

    uint256 private _totalSupplyAccelerator;
    mapping(address => uint256) private _balancesAccelerator;

    mapping(address => uint256) public userAcceleratorRewardPerTokenPaid;
    mapping(address => uint256) public acceleratorRewards;

    uint256 public acceleratorDURATION = 30 days;
    uint256 public acceleratorStartTime = 1615910400;
    uint256 public acceleratorPeriodFinish = 0;
    uint256 public acceleratorRewardRate = 0;
    uint256 public acceleratorLastUpdateTime;
    uint256 public acceleratorRewardPerTokenStored;

    uint256 public acceleratorRewardAmount;

    function changeAcceleratorToken(address token) external onlyOperator {
        acceleratorToken = IBEP20(token);
    }

    modifier accleratorCheckStart() {
        require(
            block.timestamp >= acceleratorStartTime,
            'Accelerator: not start'
        );
        _;
    }

    modifier acceleratorUpdateReward(address account) {
        acceleratorRewardPerTokenStored = acceleratorRewardPerToken();
        acceleratorLastUpdateTime = acceleratorLastTimeRewardApplicable();
        if (account != address(0)) {
            acceleratorRewards[account] = acceleratorEarned(account);
            userAcceleratorRewardPerTokenPaid[
                account
            ] = acceleratorRewardPerTokenStored;
        }
        _;
    }

    function acceleratorLastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {
        return Math.min(block.timestamp, acceleratorPeriodFinish);
    }

    function acceleratorRewardPerToken() public view returns (uint256) {
        if (totalSupplyAccelerator() == 0) {
            return acceleratorRewardPerTokenStored;
        }
        return
            acceleratorRewardPerTokenStored.add(
                acceleratorLastTimeRewardApplicable()
                    .sub(acceleratorLastUpdateTime)
                    .mul(acceleratorRewardRate)
                    .mul(1e18)
                    .div(totalSupplyAccelerator())
            );
    }

    function acceleratorEarned(address account) public view returns (uint256) {
        return
            acceleratorBalanceOf(account)
                .mul(
                acceleratorRewardPerToken().sub(
                    userAcceleratorRewardPerTokenPaid[account]
                )
            )
                .div(1e18)
                .add(acceleratorRewards[account]);
    }

    function totalSupplyAccelerator() public view returns (uint256) {
        return _totalSupplyAccelerator;
    }

    function acceleratorBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return _balancesAccelerator[account];
    }

    function stakeAccelerator(uint256 amountACG)
        public
        virtual
        acceleratorUpdateReward(msg.sender)
        accleratorCheckStart
    {
        require(amountACG > 0, 'ACGAccelerator: Cannot stake 0');

        _totalSupplyAccelerator = _totalSupplyAccelerator.add(amountACG);
        _balancesAccelerator[msg.sender] = _balancesAccelerator[msg.sender].add(
            amountACG
        );
        acceleratorToken.safeTransferFrom(msg.sender, address(this), amountACG);
    }

    function withdrawAccelerator(uint256 amount)
        public
        acceleratorUpdateReward(msg.sender)
        accleratorCheckStart
    {
        require(amount > 0, 'ACGAccelerator: Cannot withdraw 0');
        _totalSupplyAccelerator = _totalSupplyAccelerator.sub(amount);
        _balancesAccelerator[msg.sender] = _balancesAccelerator[msg.sender].sub(
            amount
        );
        acceleratorToken.safeTransfer(msg.sender, amount);
    }

    function notifyAcceleratorRewardAmount(uint256 reward)
        public
        acceleratorUpdateReward(address(0))
    {
        acceleratorRewardAmount = reward;
        acceleratorRewardRate = reward.div(acceleratorDURATION);
    }

    function setAcceleratorTimeCircle(uint256 starttime_, uint256 day)
        public
        onlyOperator
    {
        acceleratorStartTime = starttime_;
        acceleratorDURATION = day * 1 days;
        acceleratorPeriodFinish = starttime_.add(acceleratorDURATION);
        acceleratorLastUpdateTime = starttime_;
    }
}
