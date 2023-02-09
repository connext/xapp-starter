# xapp-starter

Starter kit for cross-domain apps (xApps).
# Overview

There are generally three types of cross-chain bridge transactions that can be executed solely through smart contract integration.
- Asset transfers
- Unauthenticated calls
- Authenticated calls

This starter repo contains contracts that demonstrate how to use each type of transaction.

The high level flow is as follows:

<img src="documentation/assets/xcall.png" alt="drawing" width="500"/>

## Simple Bridge

Simple asset transfer from Origin Chain to Destination Chain. Does not use calldata. 

Example use cases:
- Send funds across chains

Contracts:
- SimpleBridge.sol

## Unauthenticated Call

Transfer funds and/or call a target contract with arbitrary calldata on the Destination Chain. Assuming the receiving side is an unauthenticated call, this flow is essentially the same as the simple bridge except encoded calldata is included in the `xcall`. The call can simply use `amount: 0` if no funds are being transferred.

Example use cases:
- Deposit funds into a liquidity pool on the Destination Chain
- Execute a token Swap on the Destination Chain
- Connecting DEX liquidity across chains in a single seamless transaction
- Crosschain vault zaps and vault strategy management

Contracts:
- SourceGreeter.sol
- DestinationGreeter.sol

## Authenticated Call

Like unauthenticated, call a target contract with arbitrary calldata on the Destination Chain. Except, the target function is authenticated which means the contract must check the origin in order to uphold authentication requirements.

Example use cases:
- Hold a governance vote on Origin Chain and execute the outcome of it on the Destination Chain (and other DAO operations)
- Lock-and-mint or burn-and-mint token bridging
- Critical protocol operations such as replicating/syncing global constants (e.g. PCV) across chains
- Bringing UniV3 TWAPs to every chain without introducing oracles
- Chain-agnostic veToken governance
- Metaverse-to-metaverse interoperability

Contracts:
- SourceGreeterAuthenticated.sol
- DestinationGreeterAuthenticated.sol

## Ping Pong

An example of a nested `xcall`, when another `xcall` is executed in the destination receiver contract. 

Contracts:
- Ping.sol
- Pong.sol

# Development

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/connext/xapp-starter)

## Getting Started

This project uses Foundry for testing, deploying, and interacting with contracts. Fully compatible hardhat support will be added in the near future.

- See the official Foundry installation [instructions](https://github.com/gakonst/foundry/blob/master/README.md#installation).
- Also, download [make](https://askubuntu.com/questions/161104/how-do-i-install-make) if you don't already have it.

## Blueprint

```ml
src
├─ contract-examples
|  └─ simple-bridge
│    └─ SimpleBridge.sol
|  └─ greeter
│    └─ SourceGreeter.sol
│    └─ DestinationGreeter.sol
|  └─ greeter-authenticated
│    └─ SourceGreeterAuthenticated.sol
│    └─ DestinationGreeterAuthenticated.sol
|  └─ ping-pong
│    └─ Ping.sol
│    └─ Pong.sol
|  └─ tests
│    └─ ...
├─ sdk-examples
│    └─ node-examples
```

## Setup
```bash
make install
yarn
foundryup
```

## Set up environment variables
Copy the `.env.example` into `.env` and fill in all the placeholder variables under the `GENERAL` section.

## Testing

There are some starter test cases in the `src/tests` directory for each of the examples.

### Unit Tests

```bash
make test-unit-simple-bridge
make test-unit-destination-greeter
make test-unit-destination-greeter-auth
make test-unit-ping
make test-unit-pong
```

### Integration Tests

This uses forge's `--forked` mode. Make sure you have `GOERLI_RPC_URL` defined in your `.env` file as all the integration tests currently fork Goerli.
```bash
make test-forked-simple-bridge
make test-forked-source-greeter
make test-forked-source-greeter-auth
```

### Deployment

Deploy contracts in this repository using the RPC provider of your choice (make sure all the variables under `GENERAL` are set in `.env`).

- Deployment order for Simple Bridge

    ```bash
    make deploy-simple-bridge
    ```

- Deployment order for SourceGreeter + DestinationGreeter

    ```bash
    make deploy-source-greeter
    ```
    
    ```bash
    make deploy-destination-greeter
    ```

- Deployment order for SourceGreeterAuthenticated + DestinationGreeterAuthenticated

    ```h
    make deploy-source-greeter-auth
    ```
    
    Use the origin domain and deployed source contract address as values for `ORIGIN_DOMAIN` and `SOURCE_CONTRACT` in `.env` before deploying `DestinationGreeterAuthenticated`.

    ```bash
    make deploy-destination-greeter-auth
    ```

- Deployment order for Ping + Pong

    ```bash
    make deploy-ping
    ```
    
    ```bash
    make deploy-pong
    ```

### Verification

It's much easier to read contract values after they're verified! We use another forge command to do this.

For example, to verify `DestinationGreeter.sol`: 

```bash
forge verify-contract --chain 80001 <deployed_contract_address> src/contract-examples/greeter/DestinationGreeter.sol:DestinationGreeter <polygonscan_api_key>
```

### Live Testnet Testing

The core set of Connext contracts have already been deployed to testnet. For the most up-to-date contracts, please reference the [Connext deployments](https://github.com/connext/nxtp/tree/main/packages/deployments/contracts/deployments).

- Execute `transfer` on SimpleBridge

  After deploying SimpleBridge, set the `SIMPLE_BRIDGE` and `RECIPIENT` variables in `.env` and run:

  ```
  make transfer
  ```

- Execute `updateGreeting` on SourceGreeter

  After deploying SourceGreeter and DestinationGreeter, set the `SOURCE_GREETER`, `DESTINATION_GREETER`, `DESTINATION_TOKEN`, and `NEW_GREETING` variables in `.env` and run:

  ```
  make update-greeting
  ```

- Execute `updateGreeting` on SourceGreeterAuthenticated

  After deploying SourceGreeterAuthenticated and DestinationGreeterAuthenticated, set the `SOURCE_GREETER_AUTHENTICATED` and `DESTINATION_GREETER_AUTHENTICATED` variables in `.env` and run:

  ```
  make update-greeting-auth
  ```

- Execute `sendPing` on Ping

  After deploying Ping and Pong, set the `PING` and `PONG` variables in `.env` and run:

  ```
  make send-ping
  ```


There is also a set of Hardhat tasks available for executing transactions on deployed contracts.

- Simple Bridge

  ```bash
  yarn hardhat simpleBridge --destination-domain <domainID> --contract-address <address(SimpleBridge)> --token-address <address(origin_TestERC20)> --amount <amount>
  ```

- Hello Quickstart 

  ```bash
  yarn hardhat hello --destination-domain <domainID> --source-address <address(Source)> --target-address <address(Target)> --greeting <greeting>
  ```

- Hello Authenticated

  ```bash
  yarn hardhat helloAuthenticated --destination-domain <domainID> --source-address <address(Source)> --target-address <address(Target)> --greeting <greeting>
  ```

- Ping Pong

```bash
yarn hardhat pingPong --destination-domain <domainID> --ping-address <address(Ping)> --pong-address <address(Pong)> --token-address <address(origin_TestERC20)> --amount <amount>
```

### Check Execution Results

You can just check your wallet balance in the Simple Bridge example to see if the funds arrived at the destination address. To check calldata results, you can read the updated variables on the target contract on Etherscan or use tools like Foundry's `cast` command.
