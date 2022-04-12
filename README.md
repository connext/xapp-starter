# xapp-starter

Starter kit for cross-domain apps (xApps).
# Overview

With Connext's upgraded protocol, there are generally three types of bridging transactions that can be executed fully through smart contract integration.
- Simple transfers
- Permissionless calls
- Permissioned calls

This starter repo contains contracts that demonstrate how to use each type of transaction.

## XDomainTransfer

Simple transfer from Sending Chain to Receiving Chain. Does not use calldata. 

Example use cases:
- Send funds across chains

Contracts:
- XDomainTransfer.sol

![XDomainTransfer](documentation/assets/XDomainTransfer.png)

## XDomainPermissionless

Transfer funds and/or call a target contract with arbitrary calldata on the Receiving Chain. Assuming the receiving side is a permissionless call, this flow is essentially the same as a simple transfer except encoded calldata is included in the `xcall`.

Example use cases:
- Deposit funds from Sending Chain into a liquidity pool on the Receiving Chain

Contracts:
- XDomainPermissionless.sol

![XDomainPermissionless](documentation/assets/XDomainPermissionless.png)

## XDomainPermissioned

Transfer funds and/or call a target contract with arbitrary calldata on the Receiving Chain. With permissioned calls, middleware contracts may be needed to run `msg.sender` checks. 

Contracts:
- [TODO]

# Development

## Getting Started

This project uses Foundry for testing smart contracts and Hardhat for deploying them.

- See the official Foundry installation [instructions](https://github.com/gakonst/foundry/blob/master/README.md#installation).
- [Forge template](https://github.com/abigger87/femplate) by abigger87.

## Blueprint

```ml
src
├─ tests
│  └─ unit 
│     └─ XDomainTransfer.t.sol — "XDomainTransfer Unit Tests"
│     └─ XDomainPermissionless.t.sol — "XDomainPermissionless Unit Tests"
│  └─ integration
|     └─ XDomainTransferForked.t.sol — "XDomainTransfer Integration Tests"
|     └─ XDomainPermissionlessForked.t.sol — "XDomainPermissionless Integration Tests"
└─ Target.sol — "A contrived Target Contract"
└─ XDomainTransfer.sol — "An XDomainTransfer Contract"
└─ XDomainPermissionless.sol — "An XDomainPermissionless Contract"
```
## Setup
```bash
make
```

> If you are using an M1 mac, follow the instructions for installing Nix and dapptools [here](https://github.com/dapphub/dapptools). Double check that `/etc/nix/nix.conf` contains `system = x86_64-darwin`.
>
> During `make`, you may run into this error message: 
> ```
> error: file 'REPEAT' was not found in the Nix search path (add it using $NIX_PATH or -I)
> ```
>
> This GitHub issue [comment](https://github.com/NixOS/nixpkgs/issues/163374#issuecomment-1062480297) should help.

## Testing

### Unit Tests

```bash
make test-unit-all
make test-unit-transfer
make test-unit-permissionless
make test-unit-permissioned
```

### Integration Tests

This uses forge's `--forked` mode. Make sure you have `TESTNET_RPC_URL` defined in your `.env` file. Currently, the test cases are pointed at Connext's Kovan testnet deployments.
```
make test-forked-transfer
make test-forked-permissionless
make test-forked-permissioned
```

### Live Testnet Testing

The core set of Connext + Nomad contracts have already been deployed to testnet. For the most up-to-date contracts, please reference the [Connext deployments](https://github.com/connext/nxtp/tree/amarok/packages/deployments/contracts/deployments).

To deploy xapp contracts to testnet, see the Deployment section below.

There is a set of Hardhat tasks available for executing transactions on deployed contracts.

For the Simple Transfer example:

```
yarn hardhat transfer --contract-address <XDomainTransfer> --token-address <TestERC20> --wallet-address <your-wallet> --wallet-private-key <your-private-key>
```

For the Permissionless Deposit example:

```
yarn hardhat permissionless --contract-address <XDomainPermissionless> --token-address <TestERC20> --wallet-address <your-wallet> --wallet-private-key <your-private-key>
```

### Deployment

This command will allow you to deploy contracts in this repository using the RPC provider of your choice.

```
make deploy-testnet
```
