// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {MEVController} from "./MEVController.sol";
import {ChainlinkSourceAdapter} from "oval/src/adapters/source-adapters/ChainlinkSourceAdapter.sol";
import {ChainlinkDestinationAdapter} from "oval/src/adapters/destination-adapters/ChainlinkDestinationAdapter.sol";
import {IAggregatorV3Source} from "oval/src/interfaces/chainlink/IAggregatorV3Source.sol";
import {DiamondRootOval} from "oval/src/DiamondRootOval.sol";

/**
 * @title OvalOracle instance that has input and output adapters of Chainlink and BaseController.
 */
contract ChainlinkOvalTaxed is MEVController, ChainlinkSourceAdapter, ChainlinkDestinationAdapter {
    constructor(IAggregatorV3Source source, uint8 decimals, uint256 lockWindow, uint256 maxTraversal, uint256 maxAge)
        MEVController()
        ChainlinkSourceAdapter(source)
        ChainlinkDestinationAdapter(decimals){}

    
    /**
     * @dev this function is used in unlockLatestValue. This is simply disable that function
     */
    function snapshotData() public pure override(ChainlinkSourceAdapter, DiamondRootOval) {
        revert("Use unlockLatestValueTaxed");
    }
}