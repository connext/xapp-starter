# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean install update solc build dappbuild

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_12

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the Modules
install :; forge install # dapphub/ds-test && forge install rari-capital/solmate && forge install brockelmore/forge-std && forge install ZeframLou/clones-with-immutable-args

# Update Dependencies
update:; forge update

# Builds
build  :; forge clean && forge build --optimize --optimize-runs 1000000
dappbuild :; dapp build

# chmod scripts
scripts :; chmod +x ./scripts/*

# Tests
test-all-unit   :; forge clean && forge test --match-test "test_" --optimize --optimize-runs 1000000 -vvvv
test-transfer-unit   :; forge clean && forge test --match-contract "XDomainTransfer" --match-test "test_" --optimize --optimize-runs 1000000 -vvvv 
test-transfer-forked :; forge clean && forge test --match-contract "XDomainTransfer" --match-test "testForked_" --fork-url ${TESTNET_RPC_URL} -vvvv
test-deposit-unit   :; forge clean && forge test --match-contract "XDomainDeposit" --match-test "test_" --optimize --optimize-runs 1000000 -vvvv 
test-deposit-forked :; forge clean && forge test --match-contract "XDomainDeposit" --match-test "testForked_" --fork-url ${TESTNET_RPC_URL} -vvvv

# Lints
lint :; prettier --write src/**/*.sol && prettier --write src/*.sol

# Generate Gas Snapshots
snapshot :; forge clean && forge snapshot --optimize --optimize-runs 1000000

# Fork Mainnet With Hardhat
mainnet-fork :; npx hardhat node --fork ${ETH_MAINNET_RPC_URL}

# Rename all instances of femplate with the new repo name
rename :; chmod +x ./scripts/* && ./scripts/rename.sh