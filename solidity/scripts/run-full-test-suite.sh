#!/bin/bash
set -e

echo "=== Foundry Full Test Suite ==="
echo ""

# Build contracts
echo "→ Building contracts..."
forge build
echo "✓ Build complete"
echo ""

# Run tests with gas report
echo "→ Running tests with gas report..."
forge test --gas-report
echo ""

# Run tests with maximum verbosity on failure
echo "→ Running tests with detailed output..."
forge test -vvv
echo ""

# Generate coverage report
echo "→ Generating coverage report..."
forge coverage
echo ""

# Generate snapshot for gas optimization tracking
echo "→ Generating gas snapshot..."
forge snapshot
echo "✓ Gas snapshot saved to .gas-snapshot"
echo ""

# Check for specific test patterns
echo "→ Running fuzz tests..."
forge test --match-contract "Fuzz" -vv
echo ""

echo "→ Running invariant tests..."
forge test --match-contract "Invariant" -vv
echo ""

echo "=== Test Suite Complete ==="
echo ""
echo "Summary:"
forge test --summary
