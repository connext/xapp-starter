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
build :; forge clean && forge build

# Deployments
deploy-transfer-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${connext}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
deploy-and-verify-transfer-testnet :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${connext}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-transfer-testnet :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${connext}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-source-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address,address)" "${connext}" "${promiseRouter}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
deploy-source-testnet :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address,address)" "${connext}" "${promiseRouter}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-target-anvil :; forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address,uint32,address)" "${source}" "${originDomain}" "${connext}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
deploy-target-testnet :; forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address,uint32,address)" "${source}" "${originDomain}" "${connext}" --rpc-url ${TESTNET_DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --delay 10 --retries 3 --etherscan-api-key ${ETHERSCAN_KEY}  -vvvv

# Tests
test-unit-all :; forge clean && forge test --match-contract "TestUnit" -vvvv
test-unit-transfer :; forge clean && forge test --match-contract "TransferTestUnit" -vvvv
test-forked-transfer :; forge clean && forge test --match-contract "TransferTestForked" --fork-url ${TESTNET_ORIGIN_RPC_URL} -vvvv
test-unit-source:; forge clean && forge test --match-contract "SourceTestUnit" -vvvv
test-forked-source :; forge clean && forge test --match-contract "SourceTestForked" --fork-url ${TESTNET_ORIGIN_RPC_URL} -vvvv
test-unit-target:; forge clean && forge test --match-contract "TargetTestUnit" -vvvv
test-unit-nfthashi:; forge clean && forge test --match-contract "NFTHashiTestUnit" -vvvv
test-forked-nfthashi:; forge clean && forge test --match-contract "NFTHashiTestForked" --fork-url ${TESTNET_ORIGIN_RPC_URL} -vvvv

# Lints
lint :; prettier --write src/**/*.sol && prettier --write src/**/*.sol

# Generate Gas Snapshots
snapshot :; forge clean && forge snapshot --optimize --optimizer-runs 1000000

# Rename all instances of femplate with the new repo name
rename :; chmod +x ./scripts/* && ./scripts/rename.sh