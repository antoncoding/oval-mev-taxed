// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {BaseController} from "oval/src/controllers/BaseController.sol";
import {MEVTaxedOval} from "./MEVTaxedOval.sol";

/**
 * @title MEVController update the BaseController and remove the need of setting and checking unlockers.
 */
abstract contract MEVController is BaseController, MEVTaxedOval {
  
    ///@dev The MEV tax multiplier, people who submit the tx pays msg.fee * mevTaxMultiplier
    uint256 private mevTaxMultiplier = 100;

    event TaxMultiplierSet(uint taxMultiplier);

    error InsufficientMEVTax();

    
    /**
     * @dev Set the tax multiplier.
     * @param taxMultiplier The new tax multiplier.
     */
    function setTaxMultiplier(uint taxMultiplier) public onlyOwner {
        // todo: check if taxMultiplier is reasonable

        // set the tax rate
        mevTaxMultiplier = taxMultiplier;

        emit TaxMultiplierSet(taxMultiplier);
    }

    /**
     * @notice We use the snapshotData function to pay the MEV tax. 
     * @dev This function is called during MEVTaxedOval.unlockLatestValue(), whoever submit this tx with the highest priority fee must pay the MEV tax here.
     * 
     */
    function tax() public payable override {
        uint mevTax = (tx.gasprice - block.basefee) * mevTaxMultiplier;
        if (msg.value < mevTax) revert InsufficientMEVTax();
    }
}
