.PHONY: help install dev build test deploy-local-v2 clean

help:
	@echo "Available commands:"
	@echo "  make install         - Install all dependencies"
	@echo "  make dev            - Start development server"
	@echo "  make build          - Build production app"
	@echo "  make test           - Run contract tests"
	@echo "  make anvil          - Start local Anvil fork"
	@echo "  make deploy-local-v2 - Deploy V2 contracts to local Anvil"
	@echo "  make clean          - Clean build artifacts"

install:
	cd app && bun install
	cd contract && forge install

dev:
	cd app && bun dev

build:
	cd app && bun run build

test:
	cd contract && forge test -vvv

anvil:
	./scripts/start-anvil.sh

deploy-local-v2:
	./scripts/deploy-local-v2.sh

clean:
	rm -rf node_modules
	rm -rf app/node_modules app/.next
	rm -rf contract/cache contract/out

setup-env:
	@if [ ! -f .env ]; then \
		cp .env.template .env; \
		echo "Created .env file from template. Please update with your values."; \
	else \
		echo ".env file already exists."; \
	fi