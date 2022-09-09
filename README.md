# xapp-starter

Starter kit for cross-domain apps (xApps).
# Overview

With Connext's upgraded protocol, there are generally three types of bridging transactions that can be executed fully through smart contract integration.
- Simple transfers
- Unauthenticated calls
- Authenticated calls

This starter repo contains contracts that demonstrate how to use each type of transaction.

The high level flow is as follows:

<img src="documentation/assets/xcall.png" alt="drawing" width="500"/>

## Transfer

Simple transfer from Sending Chain to Receiving Chain. Does not use calldata. 

Example use cases:
- Send funds across chains

Contracts:
- Transfer.sol

## Unauthenticated 

Transfer funds and/or call a target contract with arbitrary calldata on the Receiving Chain. Assuming the receiving side is an unauthenticated call, this flow is essentially the same as a simple transfer except encoded calldata is included in the `xcall`. The call can simply use `amount: 0` if no transfer is required.

Example use cases:
- Deposit funds into a liquidity pool on the Receiving Chain
- Execute a token Swap on the Receiving Chain
- Connecting DEX liquidity across chains in a single seamless transaction
- Crosschain vault zaps and vault strategy management

Contracts:
- Source.sol
- Target.sol

## Authenticated

Like unauthenticated, call a target contract with arbitrary calldata on the Receiving Chain. Except, the target function is authenticated which means the contract owner must make sure to check the origin in order to uphold authentication requirements.

Example use cases:
- Hold a governance vote on Sending Chain and execute the outcome of it on the Receiving Chain (and other DAO operations)
- Lock-and-mint or burn-and-mint token bridging
- Critical protocol operations such as replicating/syncing global constants (e.g. PCV) across chains
- Bringing UniV3 TWAPs to every chain without introducing oracles
- Chain-agnostic veToken governance
- Metaverse-to-metaverse interoperability

Contracts:
- Source.sol
- Target.sol

# Development

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/connext/xapp-starter)

## Getting Started

This project uses Foundry for testing and deploying contracts. Hardhat tasks are used for interacting with deployed contracts.

- See the official Foundry installation [instructions](https://github.com/gakonst/foundry/blob/master/README.md#installation).
- Also, download [make](https://askubuntu.com/questions/161104/how-do-i-install-make) if you don't already have it.

## Blueprint

```ml
src
├─ contract-to-contract-interactions
|  └─ transfer
│    └─ Transfer.sol
|  └─ with-calldata
│    └─ Source.sol
│    └─ Target.sol
|  └─ tests
│    └─ ...
├─ sdk-interactions
│    └─ node-examples
```
## Setup
```bash
make install
yarn
```

## Set up environment variables
Copy the `.env.example` into `.env` and fill in the placeholders.

## Testing

### Unit Tests

```bash
make test-unit-all
make test-unit-transfer
make test-unit-source
make test-unit-target
```

### Integration Tests

This uses forge's `--forked` mode. Make sure you have `TESTNET_ORIGIN_RPC_URL` defined in your `.env` file.
```bash
make test-forked-transfer
make test-forked-source
```

### Deployment with Verification

Deploy contracts in this repository using the RPC provider of your choice (TESTNET_ORIGIN_RPC_URL in .env).

- Deployment order for Simple Transfer example

    ```bash
    make deploy-transfer-testnet contract=Transfer connext=<address(origin_ConnextHandler)>
    ```

- Deployment order for Source + Target of with-calldata examples

    ```bash
    make deploy-source-testnet contract=Source connext=<address(origin_ConnextHandler)> promiseRouter=<address(origin_PromiseRouter)>
    ```
    
    ```bash
    make deploy-target-testnet contract=Target source=<address(Source)> originDomain=<origin_domainID> connext=<address(destination_ConnextHandler)>
    ```

### Live Testnet Testing

The core set of Connext contracts have already been deployed to testnet. For the most up-to-date contracts, please reference the [Connext deployments](https://github.com/connext/nxtp/tree/main/packages/deployments/contracts/deployments).

There is a set of Hardhat tasks available for executing transactions on deployed contracts.

- Execute Simple Transfer

  ```bash
  yarn hardhat transfer --origin-domain <domainID> --destination-domain <domainID> --contract-address <address(Transfer)> --token-address <address(origin_TestERC20)> --amount <amount>
  ```

- Execute Unauthenticated Update

  ```bash
  yarn hardhat update --origin-domain <domainID> --destination-domain <domainID> --source-address <address(Source)> --target-address <address(Target)> --value <value> --authenticated false
  ```

- Execute Authenticated Update

  ```bash
  yarn hardhat update --origin-domain <domainID> --destination-domain <domainID> --source-address <address(Source)> --target-address <address(Target)> ---value <value> --authenticated true
  ```

### Check Execution Results

You can just check your wallet balance in the Simple Transfer case to see if the funds arrived at the destination address. For the unauthenticated/authenticated updates, you can either read the `value` from a verified Target contract on Etherscan or you can use the following `cast` command to read it directly from terminal.

```bash
cast call --chain <rinkeby|goerli|etc> <address(Target)> "value()" --rpc-url <destination_rpc_url>
```