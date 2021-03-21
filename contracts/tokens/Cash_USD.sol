// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import './BEP20Burnable.sol';

//USDT for test
contract Cash_USD_Pair is BEP20, Operator {
    /**
     * @notice Constructs the Basis Cash ERC-20 contract.
     */
    constructor() BEP20('Cash_USD_Pair', 'Cash_USD_Pair') {
        // Mints 1 Basis Cash to contract creator for initial Uniswap oracle deployment.
        // Will be burned after oracle deployment
        _mint(msg.sender, 100000000 * 10**18);
    }

    /**
     * @notice Operator mints basis cash to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of basis cash to mint to
     * @return whether the process has been done
     */
    function mint(address recipient_, uint256 amount_)
        public
        onlyOperator
        returns (bool)
    {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);

        return balanceAfter > balanceBefore;
    }
}
