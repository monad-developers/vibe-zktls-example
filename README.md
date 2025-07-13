# Vibe zkTLS

Token distribution system using zkTLS authentication on Monad Testnet.

## Tech Stack

- **Frontend**: Next.js + TypeScript + Shadcn UI
- **Smart Contracts**: Foundry + Solidity
- **zkTLS**: Primus SDK
- **Blockchain**: Monad Testnet

## Quick Start

```bash
# Setup environment
make setup-env
# Edit .env with your credentials

# Install dependencies
make install

# Start local development
make anvil           # Terminal 1: Start Anvil fork
make deploy-local-v2 # Terminal 2: Deploy contracts
make dev            # Terminal 3: Start app
```

## zkTLS Flow

1. User connects MetaMask wallet
2. Verifies Twitter account via Primus SDK
3. Submits attestation to smart contract
4. Claims 100 VIBE tokens if verification passes

## Environment Variables

```bash
# Root .env file
PRIMUS_APP_ID=your_app_id
PRIMUS_APP_SECRET=your_app_secret
NEXT_PUBLIC_CONTRACT_ADDRESS=deployed_contract_address
PRIVATE_KEY=deployer_private_key
RPC_URL=http://localhost:8545
PRIMUS_CONTRACT_ADDRESS=0x1Ad7fD53206fDc3979C672C0466A1c48AF47B431
```

## Commands

```bash
make help           # Show all commands
make test           # Run contract tests
make build          # Build production app
make clean          # Clean build artifacts
```

## Monad Testnet

- **Chain ID**: 10143
- **RPC**: https://testnet-rpc.monad.xyz
- **Explorer**: https://testnet.monadexplorer.com