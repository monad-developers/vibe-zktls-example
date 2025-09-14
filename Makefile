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
	bun install
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
	@if [ ! -f app/.env ]; then \
		cp app/.env.template app/.env; \
		echo "Created app/.env file from template. Please update with your values."; \
	else \
		echo "app/.env file already exists."; \
	fi
	@if [ ! -f contract/.env ]; then \
		cp contract/.env.template contract/.env; \
		echo "Created contract/.env file from template. Please update with your values."; \
	else \
		echo "contract/.env file already exists."; \
	fi