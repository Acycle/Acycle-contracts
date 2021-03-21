// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import './EarnedTokenAcceleratorPool.sol';

contract AcceleratorFundPool_Gov_USD is EarnedTokenAcceleratorPool {
    constructor(
        address fund,
        address governance,
        address _stake
    ) {
        mineToken = IBEP20(fund);
        acceleratorToken = IBEP20(governance);
        stakeToken = IBEP20(_stake);

        setRewardDistribution(msg.sender);
    }
}
