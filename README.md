# xapp-starter

Starter kit for cross-domain apps (xApps).
# Overview

Connext's `xcall` is a single interface that can be used to send assets and arbitrary calldata from one chain to another. 

In general, there are three types of information that can be bridged between chains.
- Asset transfers
- Unauthenticated calls
- Authenticated calls

This starter repo contains example contracts that demonstrate how these can be construted with `xcall`.

At a high level, this is the call flow between contracts:

<img src="documentation/assets/xcall.png" alt="drawing" width="500"/>

## Simple Bridge (asset transfer)

The `SimpleBridge` transfers tokens from a user on the origin chain to a specified address on the destination domain.

Since no calldata is involved, no target contract is needed.

Note that when sending tokens, the user will first have to call `approve` on the ERC20 to set a spending allowance for the `SimpleBridge` contract.

Tokens will move from the user's wallet => SimpleBridge => Connext => recipient.

### Contracts
- SimpleBridge.sol

### Use cases for this pattern
- Send funds across chains

## Greeter (asset transfer + unauthenticated call)

The `DestinationGreeter` contract on the destination chain has an `updateGreeting` function that changes a stored `greeting` variable. The `SourceGreeter` contract on the origin chain uses `xcall` to send encoded calldata for `updateGreeting`.

To demonstrate a combination of an asset transfer and an arbitrary call in a single `xcall`, the `updateGreeting` function will require a payment to update the greeting. For this example, the contract will be okay with any amount greater than 0. 

`updateGreeting` is implemented as an unauthenticated call (there are no checks to determine *who* is calling the function). And so, this flow is essentially the same as the simple bridge except encoded calldata is also included in the `xcall`.

### Contracts
- SourceGreeter.sol
- DestinationGreeter.sol

### Use cases for this pattern
- Deposit funds into a liquidity pool on the destination chain
- Execute a token swap on the destination chain
- Connect DEX liquidity across chains in a single seamless transaction
- Zap into a vault from any chain

## Greeter Authenticated (authenticated call)

The `DestinationGreeterAuthenticated` contract sets some permissioning constraints. It only allows `greeting` to be updated from `SourceGreeterAuthenticated`. In order to enforce this, the contract checks that the caller is the original sender from the origin domain.

### Contracts
- SourceGreeterAuthenticated.sol
- DestinationGreeterAuthenticated.sol

### Use cases for this pattern
- Hold a governance vote on Origin Chain and execute the outcome of it on the Destination Chain (and other DAO operations)
- Lock-and-mint or burn-and-mint token bridging
- Critical protocol operations such as replicating/syncing global constants (e.g. PCV) across chains
- Bringing UniV3 TWAPs to every chain without introducing oracles
- Chain-agnostic veToken governance
- Metaverse-to-metaverse interoperability

## Ping Pong

An example of a nested `xcall`, when another `xcall` is executed in the destination receiver contract. 

### Contracts
- Ping.sol
- Pong.sol

### Use cases for this pattern
- Implement JS-style "callbacks" to respond asynchronously between chains

# Development

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/connext/xapp-starter)

## Getting Started

This project uses Foundry for testing, deploying, and interacting with contracts. Fully compatible hardhat support will be added in the near future.

- See the official Foundry installation [instructions](https://github.com/gakonst/foundry/blob/master/README.md#installation).
- Also, download [make](https://askubuntu.com/questions/161104/how-do-i-install-make) if you don't already have it.
- Get some testnet tokens! The simplest method is to go to the testnet [Bridge UI](https://testnet.bridge.connext.network/) and mint yourself some TEST tokens. You can also call the `mint()` function directly in the TEST token contract.

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
|  └─ test
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
Copy the `.env.example` into `.env` and fill in all the placeholders under the `GENERAL` section. Initial values are provided for Goerli as origin and Optimism-Goerli as destination.

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

This uses forge's `--forked` mode. Make sure you have `GOERLI_RPC_URL` defined in your `.env` file as these tests currently fork Goerli.
```bash
make test-forked-simple-bridge
make test-forked-source-greeter
make test-forked-source-greeter-auth
```

### Deployment

Deploy contracts in this repository using the RPC provider of your choice (make sure all the variables under `GENERAL` are set in `.env`).

#### Deployment order for Simple Bridge

    ```bash
    make deploy-simple-bridge
    ```

#### Deployment order for SourceGreeter + DestinationGreeter

    ```bash
    make deploy-source-greeter
    ```
    
    ```bash
    make deploy-destination-greeter
    ```

#### Deployment order for SourceGreeterAuthenticated + DestinationGreeterAuthenticated

    ```h
    make deploy-source-greeter-auth
    ```
    
    Use the origin domain and address of `SourceGreeterAuthenticated` contract address as values for `ORIGIN_DOMAIN` and `SOURCE_CONTRACT` in `.env` before deploying `DestinationGreeterAuthenticated`.

    ```bash
    make deploy-destination-greeter-auth
    ```

#### Deployment order for Ping + Pong

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
forge verify-contract --chain 1735356532 <CONTRACT_ADDRESS> src/contract-examples/greeter/DestinationGreeter.sol:DestinationGreeter <ETHERSCAN_KEY>
```

### Live Testnet Testing

The core set of Connext contracts have already been deployed to testnet. For the most up-to-date contracts, please reference the [Connext deployments](https://github.com/connext/nxtp/tree/main/packages/deployments/contracts/deployments).

- Execute `transfer` on SimpleBridge

  After deploying SimpleBridge, set the `SIMPLE_BRIDGE` and `RECIPIENT` variables in `.env` and run:

  With Forge:
  ```
  make transfer
  ```

  With Hardhat:
  ```bash
  yarn hardhat transfer
  ```

- Execute `updateGreeting` on SourceGreeter

  After deploying SourceGreeter and DestinationGreeter, set the `SOURCE_GREETER`, `DESTINATION_GREETER`, `DESTINATION_TOKEN`, and `NEW_GREETING` variables in `.env` and run:

  With Forge:
  ```
  make update-greeting
  ```

  With Hardhat:
  ```bash
  yarn hardhat update-greeting
  ```

- Execute `updateGreeting` on SourceGreeterAuthenticated

  After deploying SourceGreeterAuthenticated and DestinationGreeterAuthenticated, set the `SOURCE_GREETER_AUTHENTICATED` and `DESTINATION_GREETER_AUTHENTICATED` variables in `.env` and run:

  With Forge:
  ```
  make update-greeting-auth
  ```

  With Hardhat:
  ```bash
  yarn hardhat update-greeting-auth
  ```

- Execute `startPingPong` on Ping

  After deploying Ping and Pong, set the `PING` and `PONG` variables in `.env` and run:

  With Forge:
  ```
  make start-ping-pong
  ```

  With Hardhat:
  ```bash
  yarn hardhat start-ping-pong
  ```

### Check Execution Results

You can just check your wallet balance in the Simple Bridge example to see if the funds arrived at the destination address. To check calldata results, you can read the updated variables on the target contract on Etherscan or use tools like Foundry's `cast` command.

# SDK Examples

There is a simple NodeJS example of using the SDK in `/src/sdk-examples/`. This example demonstrates how to configure the SDK, construct the various params (like estimating relayer fee), and call `xcall`.

The script fires off a cross-chain transfer that sends funds from your wallet on the source domain to the same address on the destination domain.

For a more detailed step-by-step, check out the [SDK Guide](https://docs.connext.network/developers/guides/sdk-guides). 

## Getting Started

- Make sure dependencies are installed.

  ```
  yarn install
  ```

- Get some testnet tokens! The simplest method is to go to the testnet [Bridge UI](https://testnet.bridge.connext.network/) and mint yourself some TEST tokens. You can also call the `mint()` function directly in the TEST token contract.

- Make sure you set your private key in `.env`

  ```
  PRIVATE_KEY = <PRIVATE_KEY>
  ```

  (Optionanal) The example uses sane defaults for a Goerli -> Optimism-Goerli transfer but feel free to change these (especially RPCs as they currently use public defaults):

  ```
  ORIGIN_RPC_URL
  GOERLI_RPC_URL
  OPTIMISM_GOERLI_RPC_URL
  ORIGIN_TOKEN
  AMOUNT
  SLIPPAGE
  ```

## Run the Example


```
yarn xtransfer
```