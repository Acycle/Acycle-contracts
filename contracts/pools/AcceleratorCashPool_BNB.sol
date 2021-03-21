// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import './EarnedETHAcceleratorPool.sol';

contract AcceleratorCashPool_BNB is EarnedETHAcceleratorPool {
    constructor(address cash, address governance) {
        mineToken = IBEP20(cash);
        acceleratorToken = IBEP20(governance);

        setRewardDistribution(msg.sender);
    }
}
