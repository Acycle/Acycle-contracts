// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "../Context.sol";


abstract contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) public virtual;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        public
        onlyOwner
        virtual
    {
        rewardDistribution = _rewardDistribution;
    }
}