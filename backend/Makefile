# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
	include .env
	export
endif

# Ensure NETWORK is set
ifndef NETWORK
	$(error NETWORK is not set. Please define it in the .env file)
endif

# Set RPC URL and account based on the network
ifeq ($(NETWORK), anvil)
	RPC_URL := $(ANVIL_RPC_URL)
	ACCOUNT := $(ANVIL_ACCOUNT)
else ifeq ($(NETWORK), sepolia)
	RPC_URL := $(SEPOLIA_RPC_URL)
	ACCOUNT := $(SEPOLIA_ACCOUNT)
else
	$(error Unsupported network: $(NETWORK). Please set NETWORK to either 'anvil' or 'sepolia' in the .env file)
endif

# Default target
all: build

# Build the project
build:
	forge build

# Test the project
test:
	forge test --rpc-url $(RPC_URL) -vvvv

# Clean the project
clean:
	forge clean

# Format the code
fmt:
	forge fmt

# Install dependencies
install:
	forge install

# Update dependencies
update:
	forge update

.PHONY: all build test clean fmt install update
