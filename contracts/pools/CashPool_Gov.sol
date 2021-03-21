// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import './EarnedTokenPool.sol';

contract CashPool_Gov is EarnedTokenPool {
    constructor(address cash, address governance) {
        mineToken = IBEP20(cash);
        stakeToken = IBEP20(governance);

        setRewardDistribution(msg.sender);
    }
}
