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

## Simple Bridge
deploy-simplebridge :; @forge script script/simple-bridge/SimpleBridge.s.sol:DeploySimpleBridge --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
deploy-simplebridge-anvil :; @forge script script/simple-bridge/SimpleBridge.s.sol:DeploySimpleBridge --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

## Hello
deploy-hellosource :; @forge script script/hello-quickstart/HelloSource.s.sol:DeployHelloSource --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
deploy-hellosource-anvil :; @forge script script/hello-quickstart/HelloSource.s.sol:DeployHelloSource --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv

deploy-hellotarget :; @forge script script/hello-quickstart/HelloTarget.s.sol:DeployHelloTarget --sig "run()" --rpc-url ${DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
deploy-hellotarget-anvil :; @forge script script/hello-quickstart/HelloTarget.s.sol:DeployHelloTarget --sig "run()" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv

## Hello Authenticated
deploy-hellosource-auth :; @forge script script/hello-authenticated/HelloSourceAuthenticated.s.sol:DeployHelloSourceAuthenticated --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
deploy-hellosource-auth-anvil :; @forge script script/hello-authenticated/HelloSourceAuthenticated.s.sol:DeployHelloSourceAuthenticated --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv

deploy-hellotarget-auth :; @forge script script/hello-authenticated/HelloTargetAuthenticated.s.sol:DeployHelloTargetAuthenticated --sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_CONTRACT}" "${DESTINATION_CONNEXT}" --rpc-url ${DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
deploy-hellotarget-auth-anvil :; @forge script script/hello-authenticated/HelloTargetAuthenticated.s.sol:DeployHelloTargetAuthenticated --sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_CONTRACT}" "${DESTINATION_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv

## Ping Pong
deploy-ping :; @forge script script/ping-pong/Ping.s.sol:DeployPing --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
deploy-ping-anvil :; @forge script script/ping-pong/Ping.s.sol:DeployPing --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv

deploy-pong :; @forge script script/ping-pong/Pong.s.sol:DeployPong --sig "run(address)" "${DESTINATION_CONNEXT}" --rpc-url ${DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
deploy-pong-anvil :; @forge script script/ping-pong/Pong.s.sol:DeployPong --sig "run(address)" "${DESTINATION_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv

# Tests
test-unit-all :; forge clean && forge test --match-contract "TestUnit" -vvvv

## Simple Bridge
test-unit-simplebridge :; forge clean && forge test --match-contract "SimpleBridgeTestUnit" -vvvv
test-forked-simplebridge :; forge clean && forge test --match-contract "SimpleBridgeTestForked" --fork-url ${ORIGIN_RPC_URL} -vvvv

## Hello
# test-unit-hellosource:; forge clean && forge test --match-contract "HelloSourceTestUnit" -vvvv
test-forked-hellosource :; forge clean && forge test --match-contract "HelloSourceTestForked" --fork-url ${ORIGIN_RPC_URL} -vvvv

test-unit-hellotarget:; forge clean && forge test --match-contract "HelloTargetTestUnit" -vvvv
# test-forked-hellotarget:; forge clean && forge test --match-contract "HelloTargetTestForked" --fork-url ${ORIGIN_RPC_URL} -vvvv

## Hello Authenticated
# test-unit-hellosource-auth:; forge clean && forge test --match-contract "HelloSourceAuthenticatedTestUnit" -vvvv
test-forked-hellosource-auth:; forge clean && forge test --match-contract "HelloSourceAuthenticatedTestForked" --fork-url ${ORIGIN_RPC_URL} -vvvv

test-unit-hellotarget-auth:; forge clean && forge test --match-contract "HelloTargetAuthenticatedTestUnit" -vvvv
# test-forked-hellotarget-auth:; forge clean && forge test --match-contract "HelloTargetAuthenticatedTestForked" --fork-url ${ORIGIN_RPC_URL} -vvvv

## Ping Pong
test-unit-ping :; forge clean && forge test --match-contract "PingTestUnit" -vvvv
# test-forked-ping :; forge clean && forge test --match-contract "PingTestForked" --fork-url ${ORIGIN_RPC_URL} -vvvv

test-unit-pong :; forge clean && forge test --match-contract "PongTestUnit" -vvvv
# test-forked-ping :; forge clean && forge test --match-contract "PongTestForked" --fork-url ${ORIGIN_RPC_URL} -vvvv

# Lints
lint :; prettier --write src/**/*.sol && prettier --write src/**/*.sol

# Generate Gas Snapshots
snapshot :; forge clean && forge snapshot --optimize --optimizer-runs 1000000

# Rename all instances of femplate with the new repo name
rename :; chmod +x ./scripts/* && ./scripts/rename.sh