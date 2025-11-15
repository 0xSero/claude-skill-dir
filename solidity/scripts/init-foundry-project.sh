#!/bin/bash
set -e

PROJECT_NAME=${1:-"my-solidity-project"}

echo "Initializing Foundry project: $PROJECT_NAME"

# Create and enter project directory
forge init "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Install common dependencies
echo "Installing OpenZeppelin contracts..."
forge install OpenZeppelin/openzeppelin-contracts --no-commit

echo "Installing OpenZeppelin upgradeable contracts..."
forge install OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit

# Create enhanced foundry.toml
cat > foundry.toml << 'EOF'
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"
optimizer = true
optimizer_runs = 200
via_ir = false

[fuzz]
runs = 256
max_test_rejects = 65536

[invariant]
runs = 256
depth = 15
fail_on_revert = true

[fmt]
line_length = 100
tab_width = 4
bracket_spacing = true

[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
sepolia = "${SEPOLIA_RPC_URL}"
polygon = "${POLYGON_RPC_URL}"
arbitrum = "${ARBITRUM_RPC_URL}"

[etherscan]
mainnet = { key = "${ETHERSCAN_API_KEY}" }
sepolia = { key = "${ETHERSCAN_API_KEY}" }
polygon = { key = "${POLYGONSCAN_API_KEY}" }
EOF

# Create .env.example
cat > .env.example << 'EOF'
# RPC URLs
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR-API-KEY
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR-API-KEY
POLYGON_RPC_URL=https://polygon-mainnet.g.alchemy.com/v2/YOUR-API-KEY

# Private Keys (NEVER commit actual keys!)
PRIVATE_KEY=your-private-key-here
DEPLOYER_PRIVATE_KEY=your-deployer-key-here

# Etherscan API Keys
ETHERSCAN_API_KEY=your-etherscan-api-key
POLYGONSCAN_API_KEY=your-polygonscan-api-key
EOF

# Update .gitignore
cat >> .gitignore << 'EOF'

# Environment variables
.env

# Coverage
coverage/
lcov.info

# Gas reports
.gas-snapshot
gas-report.txt
EOF

# Create deployment script template
mkdir -p script
cat > script/Deploy.s.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Counter.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Counter counter = new Counter();

        console.log("Counter deployed at:", address(counter));

        vm.stopBroadcast();
    }
}
EOF

echo "✓ Foundry project initialized successfully!"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  cp .env.example .env"
echo "  # Edit .env with your actual keys"
echo "  forge build"
echo "  forge test"
