#!/bin/bash

# Wait for Anvil to be ready
echo "Waiting for Anvil to start..."
sleep 2

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Use first Anvil account as deployer
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
# Real Primus contract address on Monad Testnet (forked network)
export PRIMUS_CONTRACT_ADDRESS="0x1Ad7fD53206fDc3979C672C0466A1c48AF47B431"

echo "Deploying contracts to local Anvil..."
echo "Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
echo "Primus Contract (Monad Testnet): $PRIMUS_CONTRACT_ADDRESS"

cd contract && forge script script/DeployV2.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  -vvv