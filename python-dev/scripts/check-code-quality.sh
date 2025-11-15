#!/bin/bash
set -e

echo "Running Python code quality checks..."

# Check if virtual environment is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Warning: Virtual environment not activated"
    if [ -d ".venv" ]; then
        echo "Activating .venv..."
        source .venv/bin/activate
    fi
fi

# Run ruff linter
echo "→ Running ruff linter..."
uv run ruff check . || { echo "✗ Ruff linting failed"; exit 1; }
echo "✓ Ruff linting passed"

# Run ruff formatter check
echo "→ Checking code formatting..."
uv run ruff format --check . || { echo "✗ Code formatting check failed"; exit 1; }
echo "✓ Code formatting check passed"

# Run mypy type checker
echo "→ Running mypy type checker..."
uv run mypy . || { echo "✗ Type checking failed"; exit 1; }
echo "✓ Type checking passed"

# Run pytest
echo "→ Running tests..."
uv run pytest --cov || { echo "✗ Tests failed"; exit 1; }
echo "✓ Tests passed"

echo ""
echo "✓ All quality checks passed!"
