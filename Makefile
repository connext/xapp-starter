# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean install update solc build 

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_12

# Clean the repo
clean :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the Modules
install :; forge install

# Update Dependencies
update :; forge update

# Builds
build :; forge clean && forge build --optimize --optimize-runs 1000000

# chmod scripts
scripts :; chmod +x ./scripts/*

# Tests
test-unit-all :; forge clean && forge test --match-contract "TestUnit" -vvvv
test-unit-transfer :; forge clean && forge test --match-contract "XDomainTransferTestUnit" -vvvv
test-forked-transfer :; forge clean && forge test --match-contract "XDomainTransferTestForked" --fork-url ${TESTNET_RPC_URL} -vvvv
test-unit-permissionless :; forge clean && forge test --match-contract "XDomainPermissionlessTestUnit" -vvvv
test-forked-permissionless :; forge clean && forge test --match-contract "XDomainPermissionlessTestForked" --fork-url ${TESTNET_RPC_URL} -vvvv
test-unit-permissioned :; forge clean && forge test --match-contract "XDomainPermissionedTestUnit" -vvvv
test-forked-permissioned :; forge clean && forge test --match-contract "XDomainPermissionedTestForked" --fork-url ${TESTNET_RPC_URL} -vvvv

# Deployments
deploy-testnet :; ./scripts/deploy_testnet.sh

# Lints
lint :; prettier --write src/**/*.sol && prettier --write src/**/*.sol

# Generate Gas Snapshots
snapshot :; forge clean && forge snapshot --optimize --optimize-runs 1000000

# Rename all instances of femplate with the new repo name
rename :; chmod +x ./scripts/* && ./scripts/rename.sh