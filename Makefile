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

# Lints
lint :; prettier --write src/**/*.sol && prettier --write src/**/*.sol

# Generate Gas Snapshots
snapshot :; forge clean && forge snapshot --optimize --optimizer-runs 1000000

# Rename all instances of femplate with the new repo name
rename :; chmod +x ./scripts/* && ./scripts/rename.sh


############################# Deployments #############################

# Simple Bridge
deploy-simple-bridge :; @forge script script/simple-bridge/SimpleBridge.s.sol:DeploySimpleBridge --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
# deploy-simple-bridge-anvil :; @forge script script/simple-bridge/SimpleBridge.s.sol:DeploySimpleBridge --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Greeter
deploy-source-greeter :; @forge script script/greeter/SourceGreeter.s.sol:DeploySourceGreeter --sig "run(address,address)" "${ORIGIN_CONNEXT}" "${ORIGIN_TOKEN}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
# deploy-source-greeter-anvil :; @forge script script/greeter/SourceGreeter.s.sol:DeploySourceGreeter --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv
deploy-destination-greeter :; @forge script script/greeter/DestinationGreeter.s.sol:DeployDestinationGreeter --sig "run(address)" "${DESTINATION_TOKEN}" --rpc-url ${DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
# deploy-destination-greeter-anvil :; @forge script script/greeter/DestinationGreeter.s.sol:DeployDestinationGreeter --sig "run()" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv

# Greeter Authenticated
deploy-source-greeter-auth :; @forge script script/greeter-authenticated/SourceGreeterAuthenticated.s.sol:DeploySourceGreeterAuthenticated --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv
# deploy-source-greeter-auth-anvil :; @forge script script/greeter-authenticated/SourceGreeterAuthenticated.s.sol:DeploySourceGreeterAuthenticated --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast --verify -vvvv
deploy-destination-greeter-auth :; @forge script script/greeter-authenticated/DestinationGreeterAuthenticated.s.sol:DeployDestinationGreeterAuthenticated --sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_CONNEXT}" --rpc-url ${DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
# deploy-destination-greeter-auth-anvil :; @forge script script/greeter-authenticated/DestinationGreeterAuthenticated.s.sol:DeployDestinationGreeterAuthenticated --sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv

# Ping Pong
deploy-ping :; @forge script script/ping-pong/Ping.s.sol:DeployPing --sig "run(address)" "${ORIGIN_CONNEXT}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
# deploy-ping-anvil :; @forge script script/greeter-authenticated/DestinationGreeterAuthenticated.s.sol:DeployDestinationGreeterAuthenticated --sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv
deploy-pong :; @forge script script/ping-pong/Pong.s.sol:DeployPong --sig "run(address)" "${DESTINATION_CONNEXT}" --rpc-url ${DESTINATION_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
# deploy-ping-anvil :; @forge script script/greeter-authenticated/DestinationGreeterAuthenticated.s.sol:DeployDestinationGreeterAuthenticated --sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_CONNEXT}" --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv


############################# Scripts #############################

## Simple Bridge
transfer :; @forge script script/simple-bridge/Transfer.s.sol:Transfer --sig "run(address,address,uint256,address,uint32,uint256,uint256)" "${SIMPLE_BRIDGE}" "${ORIGIN_TOKEN}" "${AMOUNT}" "${RECIPIENT}"  "${DESTINATION_DOMAIN}" "${MAX_SLIPPAGE}" "${RELAYER_FEE}" --rpc-url ${ORIGIN_RPC_URL} --broadcast

## Greeter
update-greeting :; @forge script script/greeter/UpdateGreeting.s.sol:UpdateGreeting --sig "run(address,address,uint256,address,uint32,string,uint256,uint256)" "${SOURCE_GREETER}" "${ORIGIN_TOKEN}" "${AMOUNT}" "${DESTINATION_GREETER}" "${DESTINATION_DOMAIN}" "${NEW_GREETING}" "${MAX_SLIPPAGE}" "${RELAYER_FEE}" --rpc-url ${ORIGIN_RPC_URL} --broadcast

## Greeter Authenticated
update-greeting-auth :; @forge script script/greeter-authenticated/UpdateGreetingAuthenticated.s.sol:UpdateGreetingAuthenticated --sig "run(address,address,uint32,string,uint256)" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_GREETER_AUTHENTICATED}" "${DESTINATION_DOMAIN}" "${NEW_GREETING_AUTHENTICATED}" "${RELAYER_FEE}" --rpc-url ${ORIGIN_RPC_URL} --broadcast

## Ping Pong
send-ping :; @forge script script/ping-pong/SendPing.s.sol:SendPing --sig "run(address,address,uint32,uint256)" "${PING}" "${PONG}" "${DESTINATION_DOMAIN}" "${RELAYER_FEE}" --rpc-url ${ORIGIN_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify -vvvv


############################# Tests #############################
test-unit-all :; forge clean && forge test --match-contract "TestUnit"

## Simple Bridge
test-unit-simple-bridge :; forge clean && forge test --match-contract "SimpleBridgeTestUnit" -vvvv
test-forked-simple-bridge :; forge clean && forge test --match-contract "SimpleBridgeTestForked" --fork-url ${GOERLI_RPC_URL} -vvvv

## Greeter
test-unit-source-greeter:; forge clean && forge test --match-contract "SourceGreeterTestUnit" -vvvv
test-forked-source-greeter :; forge clean && forge test --match-contract "SourceGreeterTestForked" --fork-url ${GOERLI_RPC_URL} -vvvv
test-unit-destination-greeter:; forge clean && forge test --match-contract "DestinationGreeterTestUnit" -vvvv
# [TODO] test-forked-destination-greeter:; forge clean && forge test --match-contract "DestinationGreeterTestForked" --fork-url ${GOERLI_RPC_URL} -vvvv

## Greeter Authenticated
test-unit-source-greeter-auth:; forge clean && forge test --match-contract "SourceGreeterAuthenticatedTestUnit" -vvvv
test-forked-source-greeter-auth:; forge clean && forge test --match-contract "SourceGreeterAuthenticatedTestForked" --fork-url ${GOERLI_RPC_URL} -vvvv
test-unit-destination-greeter-auth:; forge clean && forge test --match-contract "DestinationGreeterAuthenticatedTestUnit" -vvvv
# [TODO] test-forked-destination-greeter-auth:; forge clean && forge test --match-contract "DestinationGreeterAuthenticatedTestForked" --fork-url ${GOERLI_RPC_URL} -vvvv

## Ping Pong
test-unit-ping :; forge clean && forge test --match-contract "PingTestUnit" -vvvv
# [TODO] test-forked-ping :; forge clean && forge test --match-contract "PingTestForked" --fork-url ${GOERLI_RPC_URL} -vvvv

test-unit-pong :; forge clean && forge test --match-contract "PongTestUnit" -vvvv
# [TODO] test-forked-ping :; forge clean && forge test --match-contract "PongTestForked" --fork-url ${GOERLI_RPC_URL} -vvvv
