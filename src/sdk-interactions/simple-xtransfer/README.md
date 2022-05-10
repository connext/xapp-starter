# Simple xTransfer

Simple cross-chain transfer, the simplest use of the Connext SDK. This small project is for example purposes only. 

By default, the transfer will send funds from your wallet on Kovan to the same address on Rinkeby.

## Mint tokens

You may need to mint some Test Tokens first! To do so, navigate to the [Test Token (TOKEN) Contract on Kovan](https://kovan.etherscan.io/address/0xB5AabB55385bfBe31D627E2A717a7B189ddA4F8F#writeContract), go to the "Contract" > "Write Contract" tab, click "Connect to Web3" to connect with your wallet, and use the exposed "mint" function to mint yourself some tokens.

## Setup

Install dependencies

```bash
yarn
```

Make a `.env` copied from `.env.example` and fill in the placeholder values.

## Fire the xcall

```bash
yarn build
yarn xtransfer
```
