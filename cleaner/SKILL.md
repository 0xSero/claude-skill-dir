# Code Cleaner & Quality Enforcer

Expert in cleaning up code, enforcing quality standards, and ensuring projects build without errors or warnings. Specializes in removing poor practices (any types, sloppy comments, mocks, incomplete code), checking for vulnerabilities, and maintaining clean documentation. Configurable for different environments and project requirements.

## When to use this skill

- **End-of-session hook** - Run automatically at session end
- Before committing code
- Cleaning up TypeScript any types
- Removing sloppy or outdated comments
- Eliminating mock data and test stubs
- Ensuring builds complete with zero warnings
- Checking for npm/package vulnerabilities
- Cleaning up documentation
- Enforcing project-specific quality rules
- Preparing code for production

## Core Expertise

### TypeScript Quality Enforcement

#### No `any` Types
```typescript
// ❌ BAD - any types
function processData(data: any): any {
    return data.value;
}

// ✅ GOOD - proper types
interface DataInput {
    value: string;
    timestamp: number;
}

function processData(data: DataInput): string {
    return data.value;
}
```

#### Detecting and Fixing any Types
```bash
# Find all 'any' types
grep -r ":\s*any" src/ --include="*.ts" --include="*.tsx"

# More thorough search
rg ":\s*any\b|<any>|any\[\]" -t ts -t tsx

# Using TypeScript compiler
tsc --noEmit --strict 2>&1 | grep "implicitly has an 'any' type"
```

#### Auto-fix any Types (with ESLint)
```json
// .eslintrc.json
{
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "error",
    "@typescript-eslint/no-unsafe-member-access": "error",
    "@typescript-eslint/no-unsafe-call": "error",
    "@typescript-eslint/no-unsafe-return": "error"
  }
}
```

### Comment Quality

#### Clean vs Sloppy Comments
```typescript
// ❌ SLOPPY COMMENTS

// this does stuff
function doStuff() {}

// TODO: fix this later
// HACK: temporary solution
// NOTE: ask john about this
// commented out code:
// const oldFunction = () => { ... }

// ✅ CLEAN COMMENTS

/**
 * Processes user data and returns normalized format
 * @param userData - Raw user data from API
 * @returns Normalized user object
 */
function processUserData(userData: RawUserData): User {
    // Normalize email to lowercase for consistency
    const email = userData.email.toLowerCase();
    return { ...userData, email };
}
```

#### Comment Cleanup Rules
1. Remove commented-out code
2. Remove vague TODOs without context
3. Remove debug comments (console.log, etc.)
4. Replace unclear comments with clear ones
5. Remove redundant comments (that just repeat code)
6. Keep JSDoc/TSDoc for public APIs
7. Keep explanatory comments for complex logic

### Removing Mocks and Stubs

#### Detecting Mocks
```bash
# Find mock data
rg "mock|stub|fake|dummy|placeholder" --type ts --type tsx -i

# Find test-only code in production files
rg "\.test\.|\.spec\.|describe\(|it\(|jest\." src/ --type ts

# Find hardcoded test data
rg "TODO.*test|FIXME.*mock|TEMPORARY" -i
```

#### Mock Removal Checklist
- [ ] Remove test fixtures from production code
- [ ] Replace hardcoded mock data with real implementations
- [ ] Remove development-only code branches
- [ ] Clean up debug flags
- [ ] Remove placeholder functions
- [ ] Implement all TODO stubs

### Build Quality

#### Zero Warnings Build
```bash
# TypeScript - fail on warnings
tsc --noEmit --strict

# Enable all strict checks
{
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}

# ESLint - fail on warnings
eslint . --max-warnings 0

# Build with strict mode
npm run build -- --strict
```

#### Build Script
```json
// package.json
{
  "scripts": {
    "build": "tsc --noEmit && vite build",
    "build:strict": "tsc --strict --noUnusedLocals --noUnusedParameters && eslint . --max-warnings 0 && vite build",
    "type-check": "tsc --noEmit --strict",
    "lint": "eslint . --max-warnings 0",
    "lint:fix": "eslint . --fix"
  }
}
```

### Vulnerability Checking

#### npm Audit
```bash
# Check for vulnerabilities
npm audit

# Auto-fix vulnerabilities (careful!)
npm audit fix

# Check specific severity
npm audit --audit-level=moderate

# Generate audit report
npm audit --json > audit-report.json

# Fail CI on vulnerabilities
npm audit --audit-level=high
```

#### Using Better Tools
```bash
# Snyk (more comprehensive)
npx snyk test

# pnpm (better audit)
pnpm audit

# Yarn
yarn audit
```

### Documentation Cleanup

#### Outdated Documentation Detection
```python
import os
from datetime import datetime, timedelta
from pathlib import Path

def find_outdated_docs(docs_dir: str, days_old: int = 180):
    """Find documentation files that haven't been updated recently"""
    docs_dir = Path(docs_dir)
    cutoff_date = datetime.now() - timedelta(days=days_old)

    outdated = []

    for md_file in docs_dir.rglob("*.md"):
        mtime = datetime.fromtimestamp(md_file.stat().st_mtime)

        if mtime < cutoff_date:
            # Check if file mentions old versions, dates, etc.
            content = md_file.read_text()

            issues = []
            if "TODO" in content:
                issues.append("Contains TODO")
            if "FIXME" in content:
                issues.append("Contains FIXME")
            if "WIP" in content or "work in progress" in content.lower():
                issues.append("Marked as WIP")

            outdated.append({
                "file": str(md_file),
                "last_modified": mtime.strftime("%Y-%m-%d"),
                "age_days": (datetime.now() - mtime).days,
                "issues": issues
            })

    return sorted(outdated, key=lambda x: x["age_days"], reverse=True)
```

#### Documentation Quality Checks
```bash
# Check for broken links
npx markdown-link-check docs/**/*.md

# Check for spelling errors
npx cspell "docs/**/*.md"

# Lint markdown
npx markdownlint docs/

# Check for outdated dependencies mentioned in docs
rg "npm install.*@\d+\.\d+\.\d+" docs/ -i
```

### Cleaner Configuration

#### .cleanerrc.json
```json
{
  "typescript": {
    "noAnyTypes": true,
    "noUnusedVars": true,
    "strictNullChecks": true,
    "noImplicitAny": true
  },
  "comments": {
    "removeCommentedCode": true,
    "removeVagueTodos": true,
    "removeDebugComments": true,
    "requireJsdoc": ["public", "exported"]
  },
  "mocks": {
    "removeMockData": true,
    "removeTestStubs": true,
    "removePlaceholders": true
  },
  "build": {
    "noWarnings": true,
    "strictMode": true,
    "failOnLintWarnings": true
  },
  "security": {
    "checkVulnerabilities": true,
    "auditLevel": "moderate",
    "autoFix": false
  },
  "documentation": {
    "checkBrokenLinks": true,
    "checkOutdated": true,
    "maxAgeDays": 180,
    "requireChangelog": true
  },
  "customRules": [
    {
      "name": "no-console-log",
      "pattern": "console\\.log",
      "fileTypes": ["ts", "tsx", "js", "jsx"],
      "exclude": ["*.test.ts", "*.spec.ts"]
    }
  ]
}
```

### Complete Cleanup Script

```bash
#!/bin/bash
set -e

echo "=== Code Cleaner & Quality Enforcer ==="
echo ""

# Load config
CONFIG_FILE=".cleanerrc.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠️  No .cleanerrc.json found - using defaults"
fi

# 1. Check for 'any' types
echo "→ Checking for 'any' types..."
ANY_COUNT=$(rg ":\s*any\b|<any>|any\[\]" -t ts -t tsx --count-matches | awk -F: '{sum+=$2} END {print sum}')
if [ "$ANY_COUNT" -gt 0 ]; then
    echo "❌ Found $ANY_COUNT instances of 'any' type"
    rg ":\s*any\b|<any>|any\[\]" -t ts -t tsx -n
    exit 1
else
    echo "✓ No 'any' types found"
fi

# 2. Remove commented code
echo ""
echo "→ Checking for commented-out code..."
COMMENTED_CODE=$(rg "^\s*//\s*(const|let|var|function|class|import)" src/ -t ts -t tsx || true)
if [ -n "$COMMENTED_CODE" ]; then
    echo "⚠️  Found commented-out code:"
    echo "$COMMENTED_CODE"
fi

# 3. Check for TODOs/FIXMEs
echo ""
echo "→ Checking for TODO/FIXME comments..."
rg "TODO|FIXME|HACK|XXX" src/ -t ts -t tsx -n || echo "✓ No TODO/FIXME comments"

# 4. Type check with strict mode
echo ""
echo "→ Running TypeScript type check (strict)..."
tsc --noEmit --strict || { echo "❌ Type check failed"; exit 1; }
echo "✓ Type check passed"

# 5. Lint with no warnings
echo ""
echo "→ Running ESLint (max warnings: 0)..."
npx eslint . --max-warnings 0 || { echo "❌ Linting failed"; exit 1; }
echo "✓ Linting passed"

# 6. Check for unused dependencies
echo ""
echo "→ Checking for unused dependencies..."
npx depcheck --ignores="@types/*,eslint-*" || echo "⚠️  Check output above"

# 7. Security audit
echo ""
echo "→ Running security audit..."
npm audit --audit-level=moderate || { echo "❌ Security vulnerabilities found"; exit 1; }
echo "✓ No security issues"

# 8. Build test
echo ""
echo "→ Testing build..."
npm run build || { echo "❌ Build failed"; exit 1; }
echo "✓ Build successful"

# 9. Check for mocks in production code
echo ""
echo "→ Checking for mocks/stubs in production code..."
MOCKS=$(rg "mock|stub|fake|dummy" src/ -t ts -t tsx -i --glob "!*.test.*" --glob "!*.spec.*" || true)
if [ -n "$MOCKS" ]; then
    echo "⚠️  Found potential mocks in production code:"
    echo "$MOCKS"
fi

# 10. Documentation checks
echo ""
echo "→ Checking documentation..."
if [ -d "docs" ]; then
    # Check for broken links (if markdown-link-check is installed)
    if command -v markdown-link-check &> /dev/null; then
        find docs -name "*.md" -exec markdown-link-check {} \; || echo "⚠️  Broken links found"
    fi
fi

echo ""
echo "=== Cleanup Complete ==="
echo "✓ All checks passed!"
```

### Python Cleaner

```python
#!/usr/bin/env python3
"""Python code cleaner"""

import subprocess
import sys
from pathlib import Path

def check_types():
    """Check with mypy"""
    print("→ Running mypy type check...")
    result = subprocess.run(["mypy", "."], capture_output=True)
    if result.returncode != 0:
        print("❌ Type check failed")
        print(result.stdout.decode())
        return False
    print("✓ Type check passed")
    return True

def check_formatting():
    """Check code formatting with ruff"""
    print("→ Checking code formatting...")
    result = subprocess.run(["ruff", "format", "--check", "."], capture_output=True)
    if result.returncode != 0:
        print("❌ Code not formatted")
        print("Run: ruff format .")
        return False
    print("✓ Code formatted correctly")
    return True

def check_linting():
    """Check linting with ruff"""
    print("→ Running ruff linter...")
    result = subprocess.run(["ruff", "check", "."], capture_output=True)
    if result.returncode != 0:
        print("❌ Linting failed")
        print(result.stdout.decode())
        return False
    print("✓ Linting passed")
    return True

def check_tests():
    """Run tests"""
    print("→ Running tests...")
    result = subprocess.run(["pytest", "--tb=short"], capture_output=True)
    if result.returncode != 0:
        print("❌ Tests failed")
        print(result.stdout.decode())
        return False
    print("✓ Tests passed")
    return True

def main():
    """Run all checks"""
    print("=== Python Code Cleaner ===\n")

    checks = [
        check_formatting,
        check_linting,
        check_types,
        check_tests,
    ]

    for check in checks:
        if not check():
            sys.exit(1)
        print()

    print("=== All Checks Passed ===")

if __name__ == "__main__":
    main()
```

### Environment-Specific Rules

#### .cleaner/rules-typescript.json
```json
{
  "name": "TypeScript Project",
  "checks": [
    {
      "name": "no-any-types",
      "command": "rg ':\\s*any\\b|<any>|any\\[\\]' -t ts -t tsx",
      "expectEmpty": true,
      "severity": "error"
    },
    {
      "name": "type-check",
      "command": "tsc --noEmit --strict",
      "expectSuccess": true,
      "severity": "error"
    },
    {
      "name": "eslint",
      "command": "eslint . --max-warnings 0",
      "expectSuccess": true,
      "severity": "error"
    }
  ]
}
```

#### .cleaner/rules-python.json
```json
{
  "name": "Python Project",
  "checks": [
    {
      "name": "ruff-format",
      "command": "ruff format --check .",
      "expectSuccess": true,
      "severity": "error"
    },
    {
      "name": "ruff-lint",
      "command": "ruff check .",
      "expectSuccess": true,
      "severity": "error"
    },
    {
      "name": "mypy",
      "command": "mypy .",
      "expectSuccess": true,
      "severity": "error"
    },
    {
      "name": "no-print-statements",
      "command": "rg 'print\\(' src/ --glob '!*test*'",
      "expectEmpty": true,
      "severity": "warning"
    }
  ]
}
```

## Project Structure

```
project/
├── .cleanerrc.json              # Main config
├── .cleaner/
│   ├── rules-typescript.json    # TS-specific rules
│   ├── rules-python.json        # Python-specific rules
│   ├── rules-solidity.json      # Solidity-specific rules
│   └── custom-rules.json        # Project-specific rules
└── scripts/
    └── clean-check.sh           # Cleanup script
```

## Resources

The `resources/` directory contains:
- Configuration templates for different languages
- Custom rule examples
- ESLint/TSConfig strict configurations
- Pre-commit hook templates

## Scripts

The `scripts/` directory contains:
- `clean-typescript.sh` - TypeScript cleanup
- `clean-python.sh` - Python cleanup
- `clean-solidity.sh` - Solidity cleanup
- `check-all.sh` - Run all checks
- `fix-all.sh` - Auto-fix issues where possible

## Hooks

The `hooks/` directory contains:
- `pre-commit` - Run checks before commit
- `pre-push` - Run full cleanup before push
- `end-session` - Run at end of coding session

## Agents

The `agents/` directory contains:
- `type-fixer` - Fix type annotations
- `comment-cleaner` - Clean up comments
- `mock-remover` - Remove test mocks from production
- `doc-updater` - Update outdated documentation

## Quick Start

```bash
# Create config
cat > .cleanerrc.json << 'EOF'
{
  "typescript": {
    "noAnyTypes": true,
    "strictMode": true
  },
  "build": {
    "noWarnings": true
  },
  "security": {
    "checkVulnerabilities": true
  }
}
EOF

# Run cleaner
./cleaner/scripts/check-all.sh

# Auto-fix issues
./cleaner/scripts/fix-all.sh
```

## Integration with Other Skills

- Works with `/python-dev/` for Python quality checks
- Integrates with `/solidity/` for Solidity code quality
- Complements `/system-manager/` for documentation quality
- Supports all development skills by ensuring code quality

## Best Practices

1. **Run at session end** - Catch issues before commit
2. **Configure for project** - Customize rules per project
3. **Fail CI on violations** - Enforce in automation
4. **Auto-fix when safe** - Use tools like ESLint --fix
5. **Document exceptions** - Use eslint-disable sparingly with comments
6. **Keep rules updated** - Review and update periodically
7. **Make it fast** - Don't slow down development
8. **Provide helpful messages** - Guide developers to fix issues

## Notes

- Configurable for different languages and frameworks
- Can run as pre-commit hook
- Should complete quickly (< 30 seconds)
- Focus on common issues, not perfection
- Balance strictness with productivity
- Auto-fix when possible, require manual fix when not
- Clear error messages help developers fix issues
- Track metrics over time
