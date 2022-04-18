#!/usr/bin/env bash

# Read the Testnet RPC URL
echo Enter Your Testnet RPC URL:
echo Example: "https://eth-<network>.alchemyapi.io/v2/<key>"
read -s rpc

# Read the contract name
echo Which contract do you want to deploy \(eg XDomainTransfer\)?
read contract

# Read the constructor arguments
echo Enter constructor arguments separated by spaces \(eg 1 2 3\):
read -ra args

if [ -z "$args" ]
then
  forge create ./src/${contract}.sol:${contract} -i --rpc-url $rpc
else
  forge create ./src/${contract}.sol:${contract} -i --rpc-url $rpc --constructor-args ${args}
fi
