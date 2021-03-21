// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import './EarnedTokenAcceleratorPool.sol';

contract AcceleratorCashPool_BUSD is EarnedTokenAcceleratorPool {
    constructor(
        address cash,
        address governance,
        address _stake
    ) {
        mineToken = IBEP20(cash);
        acceleratorToken = IBEP20(governance);
        stakeToken = IBEP20(_stake);

        setRewardDistribution(msg.sender);
    }
}
