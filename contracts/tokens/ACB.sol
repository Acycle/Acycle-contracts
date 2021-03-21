// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "./BEP20Burnable.sol";


contract AcycleBond is BEP20, Operator {
    /**
     * @notice Constructs the Basis Cash ERC-20 contract.
     */
    constructor() BEP20("ACB", "ACB") {
        
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

    // function burn(uint256 amount) public onlyOperator override {
    //     super.burn(amount);
    // }

    // function burnFrom(address account, uint256 amount) public onlyOperator override {
    //     super.burnFrom(account, amount);
    // }
}