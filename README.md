# xapp-starter

Starter kit for cross-domain apps (xApps).
# Overview

With Connext's upgraded protocol, there are generally three types of bridging transactions that can be executed fully through smart contract integration.
- Simple transfers
- Unpermissioned calls
- Permissioned calls

This starter repo contains contracts that demonstrate how to use each type of transaction.

<img src="documentation/assets/xcall.png" alt="drawing" width="500"/>

## XDomainTransfer

Simple transfer from Sending Chain to Receiving Chain. Does not use calldata. 

Example use cases:
- Send funds across chains

Contracts:
- XDomainTransfer.sol

## XDomainUnpermissioned

Transfer funds and/or call a target contract with arbitrary calldata on the Receiving Chain. Assuming the receiving side is a unpermissioned call, this flow is essentially the same as a simple transfer except encoded calldata is included in the `xcall`. The call can simply use `amount: 0` if no transfer is required.

Example use cases:
- Deposit funds into a liquidity pool on the Receiving Chain
- Execute a token Swap on the Receiving Chain

Contracts:
- XDomainUnpermissioned.sol
- UnpermissionedTarget.sol

## XDomainPermissioned

Like unpermissioned, call a target contract with arbitrary calldata on the Receiving Chain. Except, the target function is permissioned which means the contract owner must make sure to check the origin in order to uphold permissioning requirements.

Example use cases:
- Hold a governance vote on Sending Chain and execute the outcome of it on the Receiving Chain (and other DAO operations)
- Lock-and-mint or burn-and-mint token bridging
- Connecting DEX liquidity across chains in a single seamless transaction
- Crosschain vault zaps and vault strategy management
- Critical protocol operations such as replicating/syncing global constants (e.g. PCV) across chains
- Bringing UniV3 TWAPs to every chain without introducing oracles
- Chain-agnostic veToken governance
- Metaverse-to-metaverse interoperability

Contracts:
- XDomainPermissioned.sol
- PermissionedTarget.sol

# Development

## Getting Started

This project uses Foundry for testing and deploying contracts. Hardhat tasks are used for interacting with deployed contracts.

- See the official Foundry installation [instructions](https://github.com/gakonst/foundry/blob/master/README.md#installation).
- [Forge template](https://github.com/abigger87/femplate) by abigger87.

## Blueprint

```ml
src
├─ contract-to-contract-interactions
|  └─ transfer
│    └─ XDomainTransfer.sol — "XDomainTransfer Contract"
|  └─ unpermissioned
│    └─ XDomainUnpermissioned.sol — "XDomainUnpermissioned Contract"
│    └─ UnpermissionedTarget.sol — "Target Contract"
|  └─ permissioned
│    └─ XDomainPermissioned.sol — "XDomainPermissioned Contract"
│    └─ PermissionedTarget.sol — "Target Contract"
|  └─ tests
│    └─ ...
├─ sdk-interactions
│    └─ ...
```
## Setup
```bash
make install
```

## Testing

### Unit Tests

```bash
make test-unit-all
make test-unit-transfer
make test-unit-unpermissioned
make test-unit-permissioned
```

### Integration Tests

This uses forge's `--forked` mode. Make sure you have `TESTNET_RPC_URL` defined in your `.env` file. Currently, the test cases are pointed at Connext's Kovan testnet deployments.
```
make test-forked-transfer
make test-forked-unpermissioned
make test-forked-permissioned
```

### Deployment

This command will allow you to deploy contracts in this repository using the RPC provider of your choice.

```
forge create <path/to/contract:contractName> -i --rpc-url <rpc_url> --constructor-args <space separated args>
```

- Deployment order for Simple Transfer 

    ```
    forge create src/contract-to-contract-interactions/transfer/XDomainTransfer.sol:XDomainTransfer -i --rpc-url <source_chain_rpc> --constructor-args <address(ConnextHandler)>
    ```

- Deployment order for Unpermissioned Deposit

    ```
    forge create src/contract-to-contract-interactions/unpermissioned/XDomainUnpermissioned.sol:XDomainUnpermissioned -i --rpc-url <source_chain_rpc> --constructor-args <address(ConnextHandler)>
    ```

    ``` 
    forge create src/contract-to-contract-interactions/unpermissioned/UnpermissionedTarget.sol:UnpermissionedTarget -i --rpc-url <destination_chain_rpc>
    ```

- Deployment order for Permissioned Update

    ```
    forge create src/contract-to-contract-interactions/permissioned/XDomainPermissioned.sol:XDomainPermissioned -i --rpc-url <rpc_url> --constructor-args <address(ConnextHandler)>
    ```
    
    ```
    forge create src/contract-to-contract-interactions/permissioned/PermissionedTarget.sol:PermissionedTarget -i --rpc-url <rpc_url> --constructor-args <address(XDomainPermissioned)> <origin_domainID>
    ```

### Live Testnet Testing

The core set of Connext + Nomad contracts have already been deployed to testnet. For the most up-to-date contracts, please reference the [Connext deployments](https://github.com/connext/nxtp/tree/amarok/packages/deployments/contracts/deployments).

There is a set of Hardhat tasks available for executing transactions on deployed contracts.

- Execute Simple Transfer

  ```
  yarn hardhat transfer --origin-domain <domainID> --destination-domain <domainID> --contract-address <XDomainTransfer> --token-address <address(origin_TestERC20)> --wallet-address <your_wallet_address> --wallet-private-key <your_private_key>
  ```

- Execute Unpermissioned Deposit

  ```
  yarn hardhat deposit --origin-domain <domainID> --destination-domain <domainID> --contract-address <address(XDomainUnpermissioned)> --token-address <address(origin_TestERC20)> --wallet-address <your_wallet_address> --wallet-private-key <your_private_key>
  ```

- Execute Permissioned Update

  ```
  yarn hardhat update --origin-domain <domainID> --destination-domain <domainID> --contract-address <address(XDomainPermissioned)> --middleware-address <address(PermissionedTarget)> --token-address <address(origin_TestERC20)> --wallet-address <your_wallet_address> --wallet-private-key <your_private_key>
  ```
