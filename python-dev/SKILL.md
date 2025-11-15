# Python Development Expert

Expert Python developer specializing in modern Python development workflows using UV package manager, virtual environment management, dependency handling, and best practices for clean, maintainable code.

## When to use this skill

- Working on Python projects or scripts
- Setting up Python development environments
- Managing Python dependencies and virtual environments
- Installing or updating Python packages
- Writing Python code that requires best practices
- Debugging Python applications
- Optimizing Python code performance
- Implementing Python testing strategies

## Core Expertise

### UV Package Manager
- Use `uv` instead of `pip` for all package operations (faster, more reliable)
- Create virtual environments with `uv venv` instead of `python -m venv`
- Install packages with `uv pip install` or `uv add`
- Manage dependencies with `pyproject.toml` and `uv.lock`
- Sync environments with `uv sync`
- Run scripts with `uv run`

### Environment Management
- Always use virtual environments (venvs) for project isolation
- Store venv in `.venv/` directory (standard convention)
- Add `.venv/` to `.gitignore`
- Use `pyproject.toml` for modern Python projects (PEP 517/518/621)
- Document Python version requirements clearly
- Use `.python-version` file for version pinning with tools like pyenv

### Best Practices
- Follow PEP 8 style guide (use `ruff` for linting and formatting)
- Write type hints for function signatures (use `mypy` for type checking)
- Keep functions small and focused (single responsibility principle)
- Use descriptive variable and function names
- Write docstrings for modules, classes, and functions
- Prefer explicit over implicit code
- Use context managers (`with` statements) for resource management
- Handle exceptions appropriately (avoid bare `except:` clauses)
- Keep dependencies minimal and well-documented

### Code Quality Tools
- **Ruff**: Fast linter and formatter (replaces Black, isort, flake8, pylint)
  - `uv pip install ruff`
  - `ruff check .` (lint)
  - `ruff format .` (format)
- **MyPy**: Static type checker
  - `uv pip install mypy`
  - `mypy .`
- **Pytest**: Modern testing framework
  - `uv pip install pytest pytest-cov`
  - `pytest --cov=.`

### Project Structure
```
project/
├── .python-version       # Python version (e.g., 3.12)
├── pyproject.toml        # Project metadata and dependencies
├── uv.lock               # Locked dependencies
├── .gitignore            # Include .venv/, __pycache__/, etc.
├── README.md             # Project documentation
├── src/
│   └── package_name/
│       ├── __init__.py
│       └── module.py
├── tests/
│   ├── __init__.py
│   └── test_module.py
└── .venv/                # Virtual environment (git-ignored)
```

### Modern Python Features
- Use f-strings for string formatting
- Use pathlib for file path operations
- Use dataclasses or Pydantic for data structures
- Use type hints (str, int, list[str], dict[str, int], Optional, Union, etc.)
- Use match/case for pattern matching (Python 3.10+)
- Use walrus operator `:=` when appropriate

### Dependency Management Commands
```bash
# Create new project with UV
uv init my-project
cd my-project

# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# Add dependencies
uv add requests pandas numpy
uv add --dev pytest ruff mypy

# Install from pyproject.toml
uv sync

# Run scripts in the environment
uv run python script.py
uv run pytest

# Update dependencies
uv lock --upgrade
uv sync
```

### Testing Strategy
- Write tests first when possible (TDD)
- Use pytest fixtures for setup/teardown
- Aim for high test coverage (>80%)
- Use parametrize for testing multiple inputs
- Mock external dependencies
- Test edge cases and error conditions

### Common Anti-patterns to Avoid
- Don't use global variables unnecessarily
- Don't use mutable default arguments
- Don't ignore exceptions silently
- Don't use `import *`
- Don't mix tabs and spaces
- Don't leave debug print statements in production code
- Don't use `pip` when `uv` is available (much slower)

## Resources

The `resources/` directory contains:
- Common pyproject.toml templates
- Ruff configuration examples
- MyPy configuration examples
- Pytest configuration examples

## Scripts

The `scripts/` directory contains helper scripts:
- `setup-python-project.sh` - Quick project setup with UV
- `check-code-quality.sh` - Run all quality checks (ruff, mypy, pytest)
- `update-deps.sh` - Update and sync dependencies

## Hooks

The `hooks/` directory contains:
- Pre-commit hooks for code quality checks
- Post-install hooks for environment setup

## Agents

The `agents/` directory contains specialized sub-agents:
- `dependency-analyzer` - Analyzes and optimizes dependencies
- `code-reviewer` - Reviews Python code for best practices
- `test-generator` - Generates test cases from code

## Quick Reference

### Initialize new Python project
```bash
uv init my-project
cd my-project
uv venv
source .venv/bin/activate
uv add --dev ruff mypy pytest
```

### Add dependencies
```bash
uv add requests pandas  # Runtime dependencies
uv add --dev pytest ruff mypy  # Development dependencies
```

### Run quality checks
```bash
ruff check .        # Lint
ruff format .       # Format
mypy .              # Type check
pytest              # Run tests
```

### Update dependencies
```bash
uv lock --upgrade
uv sync
```

## Integration with Other Skills

- Works with `/model-trainer/` for ML/AI project setup
- Complements `/cleaner/` for code quality enforcement
- Supports `/automater/` for Python-based automation scripts
- Integrates with `/system-manager/` for project documentation

## Notes

- Always prefer UV over pip for better performance and reliability
- Keep dependencies up to date but test thoroughly after updates
- Use virtual environments even for small scripts to avoid conflicts
- Document environment setup steps in README.md
- Commit `uv.lock` to version control for reproducibility
