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
deploy-and-verify-transfer-testnet :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${connext}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv

deploy-transfertoken-testnet :; @forge script script/transfer-token/TransferToken.s.sol:DeployTransferToken --sig "run(address)" "${connext}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-hellosource-testnet :; @forge script script/hello-chain/HelloSource.s.sol:DeployHelloSource --sig "run(address)" "${connext}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-hellotarget-testnet :; @forge script script/hello-chain/HelloTarget.s.sol:DeployHelloTarget --sig "run()" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-hellosource-auth-testnet :; @forge script script/authentication/HelloSourceAuthenticated.s.sol:DeployHelloSourceAuthenticated --sig "run(address)" "${connext}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-hellotarget-auth-testnet :; @forge script script/authentication/HelloTargetAuthenticated.s.sol:DeployHelloTargetAuthenticated --sig "run(uint32,address,address)" "${originDomain}" "${sourceContract}" "${connext}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv

deploy-transfer-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address)" "${connext}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
deploy-source-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address,address)" "${connext}" "${promiseRouter}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
deploy-source-testnet :; @forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address,address)" "${connext}" "${promiseRouter}" --rpc-url ${TESTNET_ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-target-anvil :; forge script script/${contract}.s.sol:Deploy${contract} --sig "run(address,uint32,address)" "${source}" "${originDomain}" "${connext}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
deploy-target-testnet :; forge script script/${contract}.s.sol:Deploy${contract} --sig "run(uint32,address)" "${originDomain}" "${connext}" --rpc-url ${TESTNET_DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv

# Tests
test-unit-all :; forge clean && forge test --match-contract "TestUnit" -vvvv
test-unit-transfertoken :; forge clean && forge test --match-contract "TransferTokenTestUnit" -vvvv
test-forked-transfertoken :; forge clean && forge test --match-contract "TransferTokenTestForked" --fork-url ${TESTNET_ORIGIN_RPC_URL} -vvvv
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