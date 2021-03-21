// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import './IRewardDistributionRecipient.sol';
import './Accelerator.sol';
import './EarnedTokenPool.sol';

contract EarnedTokenAcceleratorPool is EarnedTokenPool, Accelerator {
    using SafeMath for uint256;

    uint256 private tokenRewardPercent = 50;

    function totalEarned(address account) public view returns (uint256) {
        return earned(account) + acceleratorEarned(account);
    }

    function stakeAccelerator(uint256 amount)
        public
        override
        acceleratorUpdateReward(msg.sender)
        accleratorCheckStart
    {
        require(
            balanceOf(msg.sender) > 0,
            'EarnedTokenAcceleratorPool: can not accelerate before any Token staked'
        );

        super.stakeAccelerator(amount);
    }

    function withdraw(uint256 amount)
        public
        override
    {
        require(amount > 0, 'EarnedTokenAcceleratorPool: Cannot withdraw 0');
        super.withdraw(amount);

        //if not balance , exit
        if (balanceOf(msg.sender) == 0) {
            if (acceleratorBalanceOf(msg.sender) > 0) {
                withdrawAccelerator(acceleratorBalanceOf(msg.sender));
            }
        }
    }

    function exit() public override {
        if (acceleratorBalanceOf(msg.sender) > 0) {
            withdrawAccelerator(acceleratorBalanceOf(msg.sender));
        }

        super.exit();
    }

    function getReward()
        public
        override
        updateReward(msg.sender)
        acceleratorUpdateReward(msg.sender)
        needStart
    {
        uint256 reward = totalEarned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            acceleratorRewards[msg.sender] = 0;
            transferReward(reward, msg.sender);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        public
        override
        onlyRewardDistribution
        updateReward(address(0))
        acceleratorUpdateReward(address(0))
    {
        uint256 tokenRewardAmount = reward.mul(tokenRewardPercent).div(100);
        super.notifyRewardAmount(tokenRewardAmount);

        notifyAcceleratorRewardAmount(reward.sub(tokenRewardAmount));
    }

    function setTokenPercent(uint256 percent) external onlyOperator {
        tokenRewardPercent = percent;
    }

    function setTimeCircle(uint256 starttime_, uint256 day)
        public
        override
        onlyOperator
    {
        super.setTimeCircle(starttime_, day);
        setAcceleratorTimeCircle(starttime_, day);
    }
}
