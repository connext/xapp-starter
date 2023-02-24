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


### --------------------------------------------------------------------
### DEPLOYMENTS
### --------------------------------------------------------------------

# Simple Bridge
deploy-simple-bridge :; @forge script script/simple-bridge/SimpleBridge.s.sol:DeploySimpleBridge \
	--sig "run(address)" "${ORIGIN_CONNEXT}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	--verify -vvvv
deploy-simple-bridge-anvil :; @forge script script/simple-bridge/SimpleBridge.s.sol:DeploySimpleBridge \
	--sig "run(address)" "${ORIGIN_CONNEXT}" \
	--rpc-url ${LOCALHOST} \
	--private-key ${ANVIL_PRIVATE_KEY} \
	--broadcast

# Greeter
deploy-source-greeter :; @forge script script/greeter/SourceGreeter.s.sol:DeploySourceGreeter \
	--sig "run(address,address)" "${ORIGIN_CONNEXT}" "${ORIGIN_TOKEN}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	--verify -vvvv
deploy-source-greeter-anvil :; @forge script script/greeter/SourceGreeter.s.sol:DeploySourceGreeter \
	--sig "run(address,address)" "${ORIGIN_CONNEXT}" "${ORIGIN_TOKEN}" \
	--rpc-url ${LOCALHOST} \
	--private-key ${ANVIL_PRIVATE_KEY} \
	--broadcast
deploy-destination-greeter :; @forge script script/greeter/DestinationGreeter.s.sol:DeployDestinationGreeter \
	--sig "run(address)" "${DESTINATION_TOKEN}" \
	--rpc-url ${DESTINATION_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	--verify -vvvv
deploy-destination-greeter-anvil :; @forge script script/greeter/DestinationGreeter.s.sol:DeployDestinationGreeter \
	--sig "run(address)" "${DESTINATION_TOKEN}" \
	--rpc-url ${LOCALHOST} \
	--private-key ${ANVIL_PRIVATE_KEY} \
	--broadcast

# Greeter Authenticated
deploy-source-greeter-auth :; @forge script script/greeter-authenticated/SourceGreeterAuthenticated.s.sol:DeploySourceGreeterAuthenticated \
	--sig "run(address)" "${ORIGIN_CONNEXT}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	--verify -vvvv
deploy-source-greeter-auth-anvil :; @forge script script/greeter-authenticated/SourceGreeterAuthenticated.s.sol:DeploySourceGreeterAuthenticated \
	--sig "run(address)" "${ORIGIN_CONNEXT}" \
	--rpc-url ${LOCALHOST} \
	--private-key ${ANVIL_PRIVATE_KEY} \
	--broadcast
deploy-destination-greeter-auth :; @forge script script/greeter-authenticated/DestinationGreeterAuthenticated.s.sol:DeployDestinationGreeterAuthenticated \
	--sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_CONNEXT}" \
	--rpc-url ${DESTINATION_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	--verify -vvvv
deploy-destination-greeter-auth-anvil :; @forge script script/greeter-authenticated/DestinationGreeterAuthenticated.s.sol:DeployDestinationGreeterAuthenticated \
	--sig "run(uint32,address,address)" "${ORIGIN_DOMAIN}" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_CONNEXT}" \
	--rpc-url ${LOCALHOST} \
	--private-key ${ANVIL_PRIVATE_KEY} \
	--broadcast

# Ping Pong
deploy-ping :; @forge script script/ping-pong/Ping.s.sol:DeployPing \
	--sig "run(address)" "${ORIGIN_CONNEXT}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast -vvvv
deploy-ping-anvil :; @forge script script/ping-pong/Ping.s.sol:DeployPing \
	--sig "run(address)" "${ORIGIN_CONNEXT}" \
	--rpc-url ${LOCALHOST} \
	--private-key ${ANVIL_PRIVATE_KEY} \
	--broadcast
deploy-pong :; @forge script script/ping-pong/Pong.s.sol:DeployPong \
	--sig "run(address)" "${DESTINATION_CONNEXT}" \
	--rpc-url ${DESTINATION_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast -vvvv
deploy-pong-anvil :; @forge script script/ping-pong/Pong.s.sol:DeployPong \
	--sig "run(address)" "${DESTINATION_CONNEXT}" \
	--rpc-url ${LOCALHOST} \
	--private-key ${ANVIL_PRIVATE_KEY} \
	--broadcast


### --------------------------------------------------------------------
### SCRIPTS
### --------------------------------------------------------------------

# SimpleBridge.transfer()
transfer :; @forge script script/simple-bridge/Transfer.s.sol:Transfer \
	--sig "run(address,address,uint256,address,uint32,uint256,uint256)" "${SIMPLE_BRIDGE}" "${ORIGIN_TOKEN}" "${AMOUNT}" "${RECIPIENT}"  "${DESTINATION_DOMAIN}" "${MAX_SLIPPAGE}" "${RELAYER_FEE}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast

transfer-eth :; @forge script script/simple-bridge/TransferEth.s.sol:TransferEth \
	--sig "run(address,address,address,uint256,address,uint32,uint256,uint256)" "${SIMPLE_BRIDGE}" "${DESTINATION_UNWRAPPER}" "${ORIGIN_WETH}" "${AMOUNT}" "${RECIPIENT}"  "${DESTINATION_DOMAIN}" "${MAX_SLIPPAGE}" "${RELAYER_FEE}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast

# SourceGreeter.xUpdateGreeting()
update-greeting :; @forge script script/greeter/UpdateGreeting.s.sol:UpdateGreeting \
	--sig "run(address,address,uint256,address,uint32,string,uint256)" "${SOURCE_GREETER}" "${ORIGIN_TOKEN}" "${AMOUNT}" "${DESTINATION_GREETER}" "${DESTINATION_DOMAIN}" "${NEW_GREETING}" "${RELAYER_FEE}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast

# SourceGreeterAuthenticated.xUpdateGreeting()
update-greeting-auth :; @forge script script/greeter-authenticated/UpdateGreetingAuthenticated.s.sol:UpdateGreetingAuthenticated \
	--sig "run(address,address,uint32,string,uint256)" "${SOURCE_GREETER_AUTHENTICATED}" "${DESTINATION_GREETER_AUTHENTICATED}" "${DESTINATION_DOMAIN}" "${NEW_GREETING_AUTHENTICATED}" "${RELAYER_FEE}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast

# Ping.startpingPong()
start-ping-pong :; @forge script script/ping-pong/StartPingPong.s.sol:StartPingPong \
	--sig "run(address,address,uint32,uint256)" "${PING}" "${PONG}" "${DESTINATION_DOMAIN}" "${RELAYER_FEE}" \
	--rpc-url ${ORIGIN_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--broadcast


### --------------------------------------------------------------------
### CASTS
### --------------------------------------------------------------------

# Read greeting variable of DestinationGreeter
read-greeting :; @cast call "${DESTINATION_GREETER}" "greeting()(string)" --rpc-url ${DESTINATION_RPC_URL}

# Read greeting variable of DestinationGreeterAuthenticated
read-greeting-auth :; @cast call "${DESTINATION_GREETER_AUTHENTICATED}" "greeting()(string)" --rpc-url ${DESTINATION_RPC_URL}

# Read pings variable of Ping
read-pings :; @cast call "${PING}" "pings()(uint)" --rpc-url ${ORIGIN_RPC_URL}

# Read pongs variable of Pong
read-pongs :; @cast call "${PONG}" "pongs()(uint)" --rpc-url ${DESTINATION_RPC_URL}


### --------------------------------------------------------------------
### TESTS
### --------------------------------------------------------------------

test-unit-all :; forge clean && forge test --match-contract "TestUnit"
test-forked-all :; forge clean && forge test --match-contract "TestForked" --fork-url ${GOERLI_RPC_URL}

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
