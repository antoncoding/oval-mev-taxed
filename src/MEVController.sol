// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Ownable} from "../lib/solady/src/auth/Ownable.sol";
import {MEVTaxedOval} from "./MEVTaxedOval.sol";

/**
 * @title MEVController update the BaseController and remove the need of setting and checking unlockers.
 */
abstract contract MEVController is Ownable, MEVTaxedOval {
    
    ///@dev The lockWindow in seconds.
    uint256 private lockWindow_ = 60; 

    ///@dev The maximum number of rounds to traverse when looking for historical data.
    uint256 private maxTraversal_ = 10; 

    ///@dev The maximum age of a historical price that can be used
    uint256 private maxAge_ = 1 days;

    ///@dev The MEV tax multiplier, people who submit the tx pays msg.fee * mevTaxMultiplier
    uint256 private mevTaxMultiplier = 100;

    event TaxMultiplierSet(uint taxMultiplier);

    error InsufficientMEVTax();

    /**
     * @notice Not used by, always return false so Oval.unlockLatestValue() can not be used.
     */
    function canUnlock(address /*caller*/, uint256 /*_lastUnlockTime*/) public pure override returns (bool) {
        return false;
    }

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

    /**
     * @notice Enables the owner to set the lockWindow.
     * @dev If changing the lockWindow would cause Oval to return different data the permissioned actor must first
     * call unlockLatestValue through flashbots via eth_sendPrivateTransaction.
     * @param newLockWindow The lockWindow to set.
     */
    function setLockWindow(uint256 newLockWindow) public onlyOwner {
        (int256 currentAnswer, uint256 currentTimestamp,) = internalLatestData();

        lockWindow_ = newLockWindow;

        // Compare Oval results so that change in lock window does not change returned data.
        (int256 newAnswer, uint256 newTimestamp,) = internalLatestData();
        require(currentAnswer == newAnswer && currentTimestamp == newTimestamp, "Must unlock first");

        emit LockWindowSet(newLockWindow);
    }

    /**
     * @notice Enables the owner to set the maxTraversal.
     * @param newMaxTraversal The maxTraversal to set.
     */
    function setMaxTraversal(uint256 newMaxTraversal) public onlyOwner {
        maxTraversal_ = newMaxTraversal;

        emit MaxTraversalSet(newMaxTraversal);
    }

    /**
     * @notice Enables the owner to set the maxAge.
     * @param newMaxAge The maxAge to set
     */
    function setMaxAge(uint256 newMaxAge) public onlyOwner {
        maxAge_ = newMaxAge;

        emit MaxAgeSet(newMaxAge);
    }

    /**
     * @notice Time window that bounds how long the permissioned actor has to call the unlockLatestValue function after
     * a new source update is posted. If the permissioned actor does not call unlockLatestValue within this window of a
     * new source price, the latest value will be made available to everyone without going through an MEV-Share auction.
     * @return lockWindow time in seconds.
     */
    function lockWindow() public view override returns (uint256) {
        return lockWindow_;
    }

    /**
     * @notice Max number of historical source updates to traverse when looking for a historic value in the past.
     * @return maxTraversal max number of historical source updates to traverse.
     */
    function maxTraversal() public view override returns (uint256) {
        return maxTraversal_;
    }

    /**
     * @notice Max age of a historical price that can be used instead of the current price.
     */
    function maxAge() public view override returns (uint256) {
        return maxAge_;
    }
}
