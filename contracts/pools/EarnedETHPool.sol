// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import './BasePool.sol';
import './IRewardDistributionRecipient.sol';
import './Accelerator.sol';

contract EarnedETHPool is ETHPool, IRewardDistributionRecipient {
    using SafeMath for uint256;
    using Address for address;
    using SafeBEP20 for IBEP20;

    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public rewardAmount;
    uint256 public totalReward;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view virtual returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake()
        public
        payable
        override
        updateReward(msg.sender)
        needStart
    {
        uint256 amount = msg.value;
        require(amount > 0, 'ETHAcceleratorCashPool: Cannot stake 0');

        super.stake();
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        public
        virtual
        override
        updateReward(msg.sender)
    {
        require(amount > 0, 'TokenCashPool: Cannot withdraw 0');
        super.withdraw(amount);

        emit Withdrawn(msg.sender, amount);
    }

    function exit() public virtual {
        if (balanceOf(msg.sender) > 0) {
            withdraw(balanceOf(msg.sender));
        }

        getReward();
    }

    function getReward() public virtual updateReward(msg.sender) needStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            transferReward(reward, msg.sender);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        public
        virtual
        override
        onlyRewardDistribution
        updateReward(address(0))
    {
        totalReward = reward;
        rewardRate = totalReward.div(DURATION);
    }

    function setTimeCircle(uint256 starttime_, uint256 day)
        public
        virtual
        override
        onlyOperator
    {
        lastUpdateTime = starttime;
        super.setTimeCircle(starttime_, day);
    }
}
