// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Oval} from "oval/src/Oval.sol";
import {TaxBase} from "./TaxBase.sol";

/**
 * @title
 * @dev
 * Oval.sol provides permissioned updating at the execution of an MEV-share auction.
 * This contract is a POC, removing the on-chain unlockers, and instead using the MEV tax to give the back-run opportunity to the transaction with highest priority fee.
 *
 * We need a new Oval contract because the unlockLatestValue function was not payable
 *
 * @custom:security-contact bugs@umaproject.org
 */
abstract contract MEVTaxedOval is Oval, TaxBase {
    /**
     * @notice payable version of unlockLatestValue
     *
     */
    function unlockLatestValueTaxed() public payable {
        tax(); // This will be used to charge the MEV tax.

        lastUnlockTime = block.timestamp;

        emit LatestValueUnlocked(block.timestamp);
    }
}
