#!/bin/bash

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Default values
FORK_URL=${FORK_RPC_URL:-"https://testnet-rpc.monad.xyz"}
FORK_BLOCK=${FORK_BLOCK_NUMBER:-"latest"}

echo "Starting Anvil fork of Monad Testnet..."
echo "Fork URL: $FORK_URL"
echo "Fork Block: $FORK_BLOCK"

# Start Anvil with fork
if [ "$FORK_BLOCK" = "latest" ]; then
  anvil \
    --fork-url $FORK_URL \
    --chain-id 10143 \
    --accounts 10 \
    --balance 1000 \
    --host 0.0.0.0 \
    --port 8545
else
  anvil \
    --fork-url $FORK_URL \
    --fork-block-number $FORK_BLOCK \
    --chain-id 10143 \
    --accounts 10 \
    --balance 1000 \
    --host 0.0.0.0 \
    --port 8545
fi