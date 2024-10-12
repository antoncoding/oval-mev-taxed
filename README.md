# MEV-Taxed Oval

This is a proof-of-concept (POC) repository that modifies the [Oval contract](https://github.com/UMAprotocol/oval-contracts) to implement MEV tax instead of the original on-chain unlocker mechanism.

## How It Works

In this modified version:

1. Bidders now need to use `unlockLatestValueTaxed()` instead of `unlockLatestValue()`.
2. When calling `unlockLatestValueTaxed()`, bidders must attach the appropriate amount of ETH as a tax to the protocol.

This implementation leverages the concept of MEV (Miner Extractable Value) taxes to give the back-run opportunity to the transaction with the highest priority fee.

## More Information

- For more details about the original Oval workflow, please refer to the [Oval Contracts repository](https://github.com/UMAprotocol/oval-contracts).
- To learn more about MEV taxes and their potential applications, check out the article [Priority Is All You Need](https://www.paradigm.xyz/2024/06/priority-is-all-you-need) by Paradigm.

## Building the Project

To build the project, use the following Forge command:
