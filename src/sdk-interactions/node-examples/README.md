# Node examples

Simple examples using the Connext SDK and TypeScript / Nodejs.

## Test Tokens

These examples use a wallet (i.e. MetaMask) to sign transactions and send funds. You may need some Test Tokens! There are a couple ways to do this.

### Testnet Bridge UI Faucet
The simplest method is to head over to the [testnet Bridge UI](https://amarok-testnet.coinhippo.io/) and connect your wallet to use the faucet.

### Mint From Contract
You can also navigate to the [Test Token (TEST) Contract on Goerli](https://goerli.etherscan.io/address/0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1#writeContract), go to the "Contract" > "Write Contract" tab, click "Connect to Web3" to connect with your wallet, and use the exposed "mint" function to mint yourself some tokens.

## Setup

Install dependencies

```bash
yarn
```

Make a `.env` copied from `.env.example` and fill in the placeholder values.

## xtransfer

This script fires off a cross-chain transfer that sends funds from your wallet on the source domain to an address (same wallet address by default) on the destination domain.

```bash
yarn xtransfer
```

## xmint (unauthenticated)

This script fires off a cross-chain mint. Normally, minting requires authentication but our Test Token has an unauthenticated `mint` function that we can leverage for this example.

```bash
yarn xmint
```
