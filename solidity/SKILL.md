# Solidity Smart Contract Expert

Expert Solidity developer specializing in secure smart contract development, comprehensive testing with Foundry, fuzzing, deployment strategies, gas optimization, and security best practices. Deep knowledge of EVM, DeFi protocols, and common vulnerabilities.

## When to use this skill

- Writing Solidity smart contracts
- Setting up Foundry projects
- Writing comprehensive tests (unit, integration, fuzz tests)
- Deploying contracts to EVM chains
- Security auditing and vulnerability detection
- Gas optimization
- DeFi protocol development
- ERC token implementation (ERC20, ERC721, ERC1155)
- Upgradeable contract patterns
- Smart contract documentation

## Core Expertise

### Foundry Framework Mastery

#### Project Setup
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Create new project
forge init my-project
cd my-project

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std

# Build
forge build

# Test
forge test

# Test with verbosity
forge test -vvvv

# Coverage
forge coverage

# Gas report
forge test --gas-report
```

#### Foundry Project Structure
```
project/
├── foundry.toml           # Foundry configuration
├── .gitignore
├── src/                   # Smart contracts
│   └── MyContract.sol
├── test/                  # Test files
│   ├── MyContract.t.sol   # Unit tests
│   └── MyContract.fuzz.sol # Fuzz tests
├── script/                # Deployment scripts
│   └── Deploy.s.sol
└── lib/                   # Dependencies (git submodules)
    ├── forge-std/
    └── openzeppelin-contracts/
```

### Testing Excellence

#### Unit Testing
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyContract.sol";

contract MyContractTest is Test {
    MyContract public myContract;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        myContract = new MyContract();
    }

    function test_BasicFunctionality() public {
        // Arrange
        uint256 expected = 100;

        // Act
        uint256 result = myContract.doSomething(expected);

        // Assert
        assertEq(result, expected);
    }

    function testFail_ShouldRevert() public {
        myContract.restrictedFunction();
    }

    function test_RevertWithMessage() public {
        vm.expectRevert("Unauthorized");
        myContract.restrictedFunction();
    }
}
```

#### Fuzz Testing
```solidity
contract MyContractFuzzTest is Test {
    MyContract public myContract;

    function setUp() public {
        myContract = new MyContract();
    }

    // Foundry will call this with random uint256 values
    function testFuzz_Amount(uint256 amount) public {
        // Bound the input to reasonable range
        amount = bound(amount, 1, 1e6 * 1e18);

        uint256 result = myContract.calculate(amount);

        // Invariants that should always hold
        assertTrue(result >= amount);
        assertTrue(result <= amount * 2);
    }

    function testFuzz_NoOverflow(uint128 a, uint128 b) public {
        // Test with values that won't overflow
        uint256 result = myContract.add(a, b);
        assertEq(result, uint256(a) + uint256(b));
    }
}
```

#### Invariant Testing
```solidity
contract InvariantTest is Test {
    MyContract public myContract;
    Handler public handler;

    function setUp() public {
        myContract = new MyContract();
        handler = new Handler(myContract);

        // Target handler for invariant testing
        targetContract(address(handler));
    }

    // This invariant should always hold
    function invariant_totalSupplyEqualsBalances() public {
        assertEq(
            myContract.totalSupply(),
            handler.sumOfBalances()
        );
    }
}
```

### Advanced Foundry Features

#### Cheatcodes
```solidity
// Impersonate an address
vm.prank(address(0x123));
myContract.restrictedFunction();

// Start persistent impersonation
vm.startPrank(address(0x123));
// Multiple calls as this address
vm.stopPrank();

// Manipulate time
vm.warp(block.timestamp + 1 days);

// Manipulate block number
vm.roll(block.number + 100);

// Set balance
vm.deal(user1, 100 ether);

// Mock calls
vm.mockCall(
    address(token),
    abi.encodeWithSelector(IERC20.balanceOf.selector),
    abi.encode(1000e18)
);

// Expect events
vm.expectEmit(true, true, false, true);
emit Transfer(from, to, amount);

// Snapshot and revert
uint256 snapshot = vm.snapshot();
// ... do stuff ...
vm.revertTo(snapshot);
```

#### Deployment Scripts
```solidity
// script/Deploy.s.sol
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyContract.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        MyContract myContract = new MyContract();

        console.log("Deployed at:", address(myContract));

        vm.stopBroadcast();
    }
}
```

Deploy:
```bash
# Deploy to localhost
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy to testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC --broadcast --verify

# Deploy to mainnet (with verification)
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY
```

### Security Best Practices

#### Common Vulnerabilities to Avoid

**1. Reentrancy**
```solidity
// ❌ VULNERABLE
function withdraw() public {
    uint256 amount = balances[msg.sender];
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] = 0; // State update after external call
}

// ✅ SECURE - Checks-Effects-Interactions pattern
function withdraw() public {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0; // State update before external call
    (bool success,) = msg.sender.call{value: amount}("");
    require(success);
}

// ✅ SECURE - ReentrancyGuard
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyContract is ReentrancyGuard {
    function withdraw() public nonReentrant {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
    }
}
```

**2. Integer Overflow/Underflow**
```solidity
// ✅ Use Solidity 0.8.0+ (built-in overflow checks)
pragma solidity ^0.8.0;

// OR use SafeMath for older versions
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
```

**3. Access Control**
```solidity
// ✅ Use OpenZeppelin Access Control
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyContract is Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function adminFunction() public onlyRole(ADMIN_ROLE) {
        // Admin only
    }
}
```

**4. Front-Running Protection**
```solidity
// Use commit-reveal schemes
// Implement slippage protection
// Use private mempools when appropriate
```

**5. Oracle Manipulation**
```solidity
// ✅ Use time-weighted average prices (TWAP)
// ✅ Use multiple oracle sources
// ✅ Implement circuit breakers
```

**6. Denial of Service**
```solidity
// ❌ VULNERABLE - Unbounded loop
function distributeRewards() public {
    for (uint i = 0; i < users.length; i++) {
        // Can run out of gas
    }
}

// ✅ SECURE - Pagination or pull pattern
mapping(address => uint256) public rewards;

function claimReward() public {
    uint256 reward = rewards[msg.sender];
    rewards[msg.sender] = 0;
    payable(msg.sender).transfer(reward);
}
```

**7. Unchecked External Calls**
```solidity
// ❌ VULNERABLE
token.transfer(recipient, amount);

// ✅ SECURE
require(token.transfer(recipient, amount), "Transfer failed");

// ✅ SECURE - Using SafeERC20
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;

token.safeTransfer(recipient, amount);
```

### Gas Optimization Techniques

#### Storage Optimization
```solidity
// ❌ Expensive - Multiple storage slots
bool public isActive;      // Slot 0
uint128 public count;      // Slot 1
address public owner;      // Slot 2

// ✅ Optimized - Packed into fewer slots
address public owner;      // Slot 0 (20 bytes)
uint128 public count;      // Slot 0 (16 bytes) - packed with owner
bool public isActive;      // Slot 0 (1 byte) - packed

// ✅ Use constants and immutable when possible
uint256 public constant RATE = 100;
address public immutable TOKEN;
```

#### Memory vs Calldata
```solidity
// ❌ Expensive for external functions
function process(uint256[] memory data) external {
    // ...
}

// ✅ Cheaper - use calldata for external functions
function process(uint256[] calldata data) external {
    // ...
}
```

#### Efficient Loops
```solidity
// ❌ Expensive
for (uint256 i = 0; i < array.length; i++) {
    // array.length is read from storage each iteration
}

// ✅ Optimized
uint256 length = array.length;
for (uint256 i = 0; i < length; i++) {
    // ...
}

// ✅ Even better - unchecked increment
uint256 length = array.length;
for (uint256 i = 0; i < length;) {
    // ...
    unchecked { ++i; }
}
```

#### Short-Circuit Evaluation
```solidity
// ✅ Put cheaper checks first
require(msg.sender == owner && expensiveCheck(), "Failed");
```

### Foundry Configuration

#### foundry.toml
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"
optimizer = true
optimizer_runs = 200
via_ir = false

# Fuzz testing configuration
[fuzz]
runs = 256
max_test_rejects = 65536

# Invariant testing configuration
[invariant]
runs = 256
depth = 15
fail_on_revert = true

# RPC endpoints
[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
sepolia = "${SEPOLIA_RPC_URL}"
polygon = "${POLYGON_RPC_URL}"

# Etherscan API keys
[etherscan]
mainnet = { key = "${ETHERSCAN_API_KEY}" }
sepolia = { key = "${ETHERSCAN_API_KEY}" }
```

### Contract Patterns

#### Proxy/Upgradeable Contracts
```solidity
// Use OpenZeppelin's upgradeable contracts
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyContract is Initializable, OwnableUpgradeable {
    function initialize() public initializer {
        __Ownable_init();
    }
}
```

#### Factory Pattern
```solidity
contract TokenFactory {
    event TokenCreated(address tokenAddress);

    function createToken(string memory name, string memory symbol)
        public
        returns (address)
    {
        Token token = new Token(name, symbol);
        emit TokenCreated(address(token));
        return address(token);
    }
}
```

### Documentation Standards

#### NatSpec Comments
```solidity
/// @title A simple token contract
/// @author Your Name
/// @notice This contract implements basic token functionality
/// @dev Implements ERC20 standard
contract MyToken {
    /// @notice Transfers tokens to a recipient
    /// @dev Emits a Transfer event
    /// @param recipient The address receiving tokens
    /// @param amount The number of tokens to transfer
    /// @return success Whether the transfer succeeded
    function transfer(address recipient, uint256 amount)
        public
        returns (bool success)
    {
        // Implementation
    }
}
```

### Deployment Checklist

- [ ] All tests passing (unit, integration, fuzz, invariant)
- [ ] Gas optimization reviewed
- [ ] Security audit completed
- [ ] Access controls properly configured
- [ ] Emergency pause mechanism implemented (if needed)
- [ ] Upgradeable proxy setup verified (if using)
- [ ] Events properly emitted
- [ ] NatSpec documentation complete
- [ ] Constructor parameters verified
- [ ] Initial state properly set
- [ ] Testnet deployment and verification successful
- [ ] Contract verified on block explorer
- [ ] Deployment script tested
- [ ] Multi-sig setup for admin functions (if needed)

## Resources

The `resources/` directory contains:
- Smart contract templates (ERC20, ERC721, ERC1155)
- Common patterns (Proxy, Factory, etc.)
- Security checklists
- Gas optimization guides
- Foundry configuration templates
- Deployment script templates

## Scripts

The `scripts/` directory contains:
- `init-foundry-project.sh` - Initialize new Foundry project
- `run-full-test-suite.sh` - Run all tests with coverage
- `deploy-testnet.sh` - Deploy to testnet
- `deploy-mainnet.sh` - Deploy to mainnet with verification
- `verify-contract.sh` - Verify on Etherscan
- `gas-report.sh` - Generate gas optimization report

## Hooks

The `hooks/` directory contains:
- Pre-commit hooks for test validation
- Pre-deploy security checks
- Gas limit warnings

## Agents

The `agents/` directory contains:
- `security-auditor` - Automated security analysis
- `gas-optimizer` - Gas optimization suggestions
- `test-generator` - Generate test cases from contracts
- `deployment-manager` - Manage multi-chain deployments

## Essential Commands Quick Reference

```bash
# Testing
forge test                          # Run all tests
forge test -vvvv                    # Maximum verbosity
forge test --match-contract Token   # Test specific contract
forge test --match-test testTransfer # Test specific function
forge test --gas-report             # Show gas usage

# Coverage
forge coverage                      # Generate coverage report
forge coverage --report lcov        # Generate lcov report

# Fuzzing
forge test --fuzz-runs 10000        # More fuzz runs

# Deployment
forge create src/MyContract.sol:MyContract --rpc-url $RPC --private-key $KEY

# Verification
forge verify-contract <address> src/MyContract.sol:MyContract --chain-id 1 --etherscan-api-key $KEY

# Interaction
cast call <address> "balanceOf(address)" <user> --rpc-url $RPC
cast send <address> "transfer(address,uint256)" <to> 100 --rpc-url $RPC --private-key $KEY

# Utilities
cast abi-encode "transfer(address,uint256)" <addr> 100
cast keccak "Transfer(address,address,uint256)"
cast --to-wei 1 ether
```

## Integration with Other Skills

- Works with `/python-dev/` for analysis scripts and tooling
- Complements `/security/` for smart contract auditing
- Integrates with `/cleaner/` for code quality
- Supports `/automater/` for deployment automation

## Security Audit Checklist

### Code Review
- [ ] Follow Checks-Effects-Interactions pattern
- [ ] No reentrancy vulnerabilities
- [ ] Proper access controls
- [ ] No integer overflow/underflow issues (or use 0.8.0+)
- [ ] External calls handled safely
- [ ] No unbounded loops
- [ ] Proper error handling
- [ ] Events emitted for state changes

### Testing
- [ ] >95% code coverage
- [ ] Fuzz tests for critical functions
- [ ] Invariant tests for protocol invariants
- [ ] Edge cases tested
- [ ] Failure scenarios tested

### Gas Optimization
- [ ] Storage layout optimized
- [ ] Unnecessary storage reads eliminated
- [ ] Calldata used where appropriate
- [ ] Loops optimized
- [ ] Constants and immutables used

### Documentation
- [ ] NatSpec comments complete
- [ ] Complex logic explained
- [ ] Assumptions documented
- [ ] Known limitations noted

## Notes

- Always test on testnet before mainnet deployment
- Use multi-sig wallets for admin functions on mainnet
- Implement timelock for critical parameter changes
- Have emergency pause functionality for high-value contracts
- Consider formal verification for critical contracts
- Stay updated on latest Solidity security practices
- Use latest stable Solidity version
- Audit third-party dependencies
- Monitor deployed contracts for unusual activity
