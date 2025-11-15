#!/bin/bash
set -e

PROJECT_NAME=${1:-"my-project"}

echo "Setting up Python project: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize UV project
uv init

# Create virtual environment
uv venv

# Create directory structure
mkdir -p src/"$PROJECT_NAME" tests

# Create __init__.py files
touch src/"$PROJECT_NAME"/__init__.py
touch tests/__init__.py

# Add dev dependencies
uv add --dev pytest pytest-cov ruff mypy

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
.venv/
venv/
ENV/
env/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# Testing
.coverage
.pytest_cache/
htmlcov/
.tox/
.mypy_cache/
.ruff_cache/

# OS
.DS_Store
Thumbs.db
EOF

# Create README
cat > README.md << EOF
# $PROJECT_NAME

## Setup

\`\`\`bash
# Create and activate virtual environment
uv venv
source .venv/bin/activate  # On Windows: .venv\\Scripts\\activate

# Install dependencies
uv sync
\`\`\`

## Development

\`\`\`bash
# Run tests
uv run pytest

# Lint and format
uv run ruff check .
uv run ruff format .

# Type check
uv run mypy .
\`\`\`
EOF

echo "✓ Project $PROJECT_NAME created successfully!"
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  source .venv/bin/activate"
echo "  uv sync"
