# System & Documentation Manager

Expert in managing system documentation, knowledge bases, RAG (Retrieval-Augmented Generation) systems, notifications, and tracking what has/hasn't worked. Ensures continuous documentation, organized knowledge management, and intelligent information retrieval through integration with external agents.

## When to use this skill

- Creating and maintaining documentation
- Setting up RAG systems for knowledge retrieval
- Organizing project documentation
- Tracking decisions and outcomes
- Managing notification systems
- Building knowledge bases
- Documenting what works and what doesn't
- Creating searchable documentation
- Maintaining project wikis
- Integrating with external documentation agents

## Core Expertise

### Documentation Management

#### Documentation Philosophy
- **Document continuously** - Don't wait until the end
- **Document decisions** - Especially why, not just what
- **Track failures** - What didn't work and why
- **Keep it searchable** - Structure for easy retrieval
- **Automate where possible** - Reduce manual effort

#### Documentation Structure
```
project/
├── docs/
│   ├── README.md                # Project overview
│   ├── ARCHITECTURE.md          # System architecture
│   ├── API.md                   # API documentation
│   ├── DEPLOYMENT.md            # Deployment guide
│   ├── TROUBLESHOOTING.md       # Common issues
│   ├── decisions/               # Decision records
│   │   ├── 001-database-choice.md
│   │   └── 002-authentication.md
│   ├── what-works/              # Successful approaches
│   │   └── deployment-process.md
│   ├── what-doesnt-work/        # Failed approaches (lessons learned)
│   │   └── attempted-optimization.md
│   └── guides/                  # How-to guides
│       ├── setup.md
│       └── testing.md
├── .knowledge-base/             # RAG knowledge base
│   ├── embeddings/
│   └── index/
└── notifications/               # Notification configs
    └── config.yaml
```

#### Architecture Decision Records (ADR)
```markdown
# ADR-001: Database Choice

## Status
Accepted

## Context
We need to store user data with complex relationships and need ACID compliance.

## Decision
We will use PostgreSQL as our primary database.

## Consequences

### Positive
- ACID compliance
- Rich query capabilities
- Strong ecosystem
- Good performance for our use case

### Negative
- More complex than NoSQL for simple queries
- Requires more operational overhead

## Alternatives Considered
- MongoDB - Rejected: Need ACID compliance
- SQLite - Rejected: Need multi-user support

## Date
2025-11-15
```

### RAG System Setup

#### Building a Documentation RAG System
```python
from langchain_community.document_loaders import DirectoryLoader, MarkdownLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma
from langchain.chains import RetrievalQA
from langchain_community.llms import Ollama

class DocumentationRAG:
    """RAG system for project documentation"""

    def __init__(self, docs_dir: str, persist_dir: str = ".knowledge-base"):
        self.docs_dir = docs_dir
        self.persist_dir = persist_dir

        # Initialize embeddings (local, no API needed)
        self.embeddings = HuggingFaceEmbeddings(
            model_name="sentence-transformers/all-MiniLM-L6-v2"
        )

        # Initialize vector store
        self.vectorstore = None
        self.load_or_create_vectorstore()

    def load_or_create_vectorstore(self):
        """Load existing or create new vector store"""
        from pathlib import Path

        if Path(self.persist_dir).exists():
            # Load existing
            self.vectorstore = Chroma(
                persist_directory=self.persist_dir,
                embedding_function=self.embeddings
            )
            print("Loaded existing knowledge base")
        else:
            # Create new
            self.vectorstore = self.create_vectorstore()
            print("Created new knowledge base")

    def create_vectorstore(self):
        """Create vector store from documentation"""
        # Load markdown files
        loader = DirectoryLoader(
            self.docs_dir,
            glob="**/*.md",
            loader_cls=MarkdownLoader
        )
        documents = loader.load()

        # Split into chunks
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=200,
            separators=["\n## ", "\n### ", "\n", " ", ""]
        )
        splits = text_splitter.split_documents(documents)

        # Create and persist vectorstore
        vectorstore = Chroma.from_documents(
            documents=splits,
            embedding=self.embeddings,
            persist_directory=self.persist_dir
        )
        vectorstore.persist()

        return vectorstore

    def update_vectorstore(self):
        """Update vectorstore with new/changed documents"""
        # Delete old vectorstore
        import shutil
        if Path(self.persist_dir).exists():
            shutil.rmtree(self.persist_dir)

        # Recreate
        self.vectorstore = self.create_vectorstore()

    def query(self, question: str, k: int = 3) -> str:
        """Query the documentation"""
        # Create retrieval chain
        qa_chain = RetrievalQA.from_chain_type(
            llm=Ollama(model="llama3.2"),  # Local LLM
            chain_type="stuff",
            retriever=self.vectorstore.as_retriever(
                search_kwargs={"k": k}
            ),
            return_source_documents=True
        )

        result = qa_chain({"query": question})

        # Format response with sources
        answer = result["result"]
        sources = [doc.metadata.get("source", "") for doc in result["source_documents"]]

        response = f"{answer}\n\nSources:\n"
        for source in set(sources):
            response += f"- {source}\n"

        return response

    def similar_docs(self, query: str, k: int = 5):
        """Find similar documentation sections"""
        docs = self.vectorstore.similarity_search(query, k=k)

        results = []
        for doc in docs:
            results.append({
                "content": doc.page_content[:200] + "...",
                "source": doc.metadata.get("source", "unknown"),
                "full_content": doc.page_content
            })

        return results
```

### What Works / What Doesn't Tracking

#### Success/Failure Logger
```python
from datetime import datetime
from pathlib import Path
import yaml

class OutcomeTracker:
    """Track what works and what doesn't"""

    def __init__(self, base_dir: str = "docs"):
        self.base_dir = Path(base_dir)
        self.works_dir = self.base_dir / "what-works"
        self.doesnt_work_dir = self.base_dir / "what-doesnt-work"

        self.works_dir.mkdir(parents=True, exist_ok=True)
        self.doesnt_work_dir.mkdir(parents=True, exist_ok=True)

    def log_success(
        self,
        title: str,
        description: str,
        category: str,
        details: dict = None
    ):
        """Log a successful approach"""
        filename = self._make_filename(title)
        filepath = self.works_dir / f"{filename}.md"

        content = f"""# {title}

**Category:** {category}
**Date:** {datetime.now():%Y-%m-%d}
**Status:** ✅ Works

## Description
{description}

## Details
"""
        if details:
            for key, value in details.items():
                content += f"\n### {key}\n{value}\n"

        content += f"""

## Reproducible Steps
1. [Add steps here]

## Notes
- [Add any additional notes]

## Related
- [Link to related documentation]
"""

        with open(filepath, 'w') as f:
            f.write(content)

        print(f"✅ Success logged: {filepath}")

    def log_failure(
        self,
        title: str,
        description: str,
        category: str,
        why_failed: str,
        lessons_learned: str,
        details: dict = None
    ):
        """Log a failed approach (valuable for learning)"""
        filename = self._make_filename(title)
        filepath = self.doesnt_work_dir / f"{filename}.md"

        content = f"""# {title}

**Category:** {category}
**Date:** {datetime.now():%Y-%m-%d}
**Status:** ❌ Doesn't Work

## What We Tried
{description}

## Why It Failed
{why_failed}

## Lessons Learned
{lessons_learned}

## Details
"""
        if details:
            for key, value in details.items():
                content += f"\n### {key}\n{value}\n"

        content += f"""

## What to Try Instead
- [Alternative approaches]

## References
- [Related documentation or issues]
"""

        with open(filepath, 'w') as f:
            f.write(content)

        print(f"❌ Failure logged (valuable lesson): {filepath}")

    @staticmethod
    def _make_filename(title: str) -> str:
        """Convert title to filename"""
        import re
        # Convert to lowercase, replace spaces with hyphens
        filename = title.lower().replace(" ", "-")
        # Remove special characters
        filename = re.sub(r'[^a-z0-9-]', '', filename)
        return filename

    def search_outcomes(self, query: str) -> dict:
        """Search through outcomes"""
        results = {"works": [], "doesnt_work": []}

        # Search what works
        for filepath in self.works_dir.glob("*.md"):
            with open(filepath) as f:
                content = f.read()
                if query.lower() in content.lower():
                    results["works"].append({
                        "title": filepath.stem,
                        "path": str(filepath)
                    })

        # Search what doesn't work
        for filepath in self.doesnt_work_dir.glob("*.md"):
            with open(filepath) as f:
                content = f.read()
                if query.lower() in content.lower():
                    results["doesnt_work"].append({
                        "title": filepath.stem,
                        "path": str(filepath)
                    })

        return results
```

### Notification System

#### Notification Manager
```python
import smtplib
from email.message import EmailMessage
from typing import List, Dict
import requests

class NotificationManager:
    """
    Manage notifications across different channels.
    User will configure with their own agents/services.
    """

    def __init__(self, config_path: str = "notifications/config.yaml"):
        self.config = self._load_config(config_path)
        # User will configure actual notification channels

    def notify(
        self,
        title: str,
        message: str,
        level: str = "info",
        channels: List[str] = None
    ):
        """
        Send notification through configured channels
        Level: info, warning, error, critical
        """
        if not channels:
            channels = self.config.get("default_channels", ["console"])

        for channel in channels:
            try:
                if channel == "console":
                    self._notify_console(title, message, level)
                elif channel == "email":
                    self._notify_email(title, message, level)
                elif channel == "slack":
                    self._notify_slack(title, message, level)
                elif channel == "custom":
                    # User will implement custom notification agent
                    self._notify_custom_agent(title, message, level)
            except Exception as e:
                print(f"Failed to send notification via {channel}: {e}")

    def _notify_console(self, title: str, message: str, level: str):
        """Console notification"""
        icons = {
            "info": "ℹ️",
            "warning": "⚠️",
            "error": "❌",
            "critical": "🚨"
        }
        icon = icons.get(level, "ℹ️")
        print(f"\n{icon} {title}\n{message}\n")

    def _notify_email(self, title: str, message: str, level: str):
        """Email notification (user must configure SMTP)"""
        if "email" not in self.config:
            return

        email_config = self.config["email"]

        msg = EmailMessage()
        msg["Subject"] = f"[{level.upper()}] {title}"
        msg["From"] = email_config["from"]
        msg["To"] = email_config["to"]
        msg.set_content(message)

        # User needs to configure SMTP settings
        # with smtplib.SMTP(email_config["smtp_server"]) as smtp:
        #     smtp.send_message(msg)

        print(f"[Email notification would be sent: {title}]")

    def _notify_slack(self, title: str, message: str, level: str):
        """Slack notification (user must configure webhook)"""
        if "slack" not in self.config:
            return

        webhook_url = self.config["slack"]["webhook_url"]

        payload = {
            "text": f"*{title}*\n{message}",
            "username": "System Manager",
        }

        # requests.post(webhook_url, json=payload)
        print(f"[Slack notification would be sent: {title}]")

    def _notify_custom_agent(self, title: str, message: str, level: str):
        """
        Custom notification agent integration
        User will implement their own notification agent
        """
        print(f"[Custom agent notification: {title}]")
        # TODO: User implements custom agent integration

    def _load_config(self, config_path: str) -> dict:
        """Load notification configuration"""
        from pathlib import Path

        if not Path(config_path).exists():
            return {"default_channels": ["console"]}

        with open(config_path) as f:
            return yaml.safe_load(f)
```

### Integration with External Agents

#### Agent Scaffolding
```python
class ExternalAgentConnector:
    """
    Scaffold for connecting to external agents
    User will configure actual agent connections
    """

    def __init__(self, agent_config: dict = None):
        self.config = agent_config or {}
        # User will add actual agent connections

    async def call_documentation_agent(self, task: str, context: dict):
        """
        Call external documentation agent
        User implements actual agent communication
        """
        print(f"[Would call documentation agent for: {task}]")
        # TODO: Implement actual agent call
        return {"status": "pending", "task": task}

    async def call_knowledge_agent(self, query: str):
        """
        Call external knowledge management agent
        """
        print(f"[Would call knowledge agent with: {query}]")
        # TODO: Implement actual agent call
        return {"status": "pending", "query": query}

    async def trigger_notification_agent(self, notification: dict):
        """
        Trigger external notification agent
        """
        print(f"[Would trigger notification agent: {notification}]")
        # TODO: Implement actual agent trigger
        return {"status": "pending", "notification": notification}
```

### Automated Documentation

#### Auto-Documentation Generator
```python
class AutoDocGenerator:
    """Generate documentation automatically"""

    def document_code_changes(self, git_diff: str) -> str:
        """Generate documentation from code changes"""
        # Use LLM to analyze changes and generate docs
        prompt = f"""Analyze these code changes and generate documentation:

{git_diff}

Create documentation that explains:
1. What changed
2. Why (if evident from commit messages)
3. Impact on users/developers
4. Any new APIs or changes to existing ones
"""
        # User can integrate with LLM here
        return "[Generated documentation based on changes]"

    def generate_api_docs(self, code_files: List[str]) -> str:
        """Generate API documentation from code"""
        # Parse code and extract API information
        # Generate markdown documentation
        return "[Generated API documentation]"

    def update_changelog(self, version: str, changes: List[str]):
        """Update CHANGELOG.md"""
        from pathlib import Path

        changelog = Path("CHANGELOG.md")

        new_entry = f"""
## [{version}] - {datetime.now():%Y-%m-%d}

### Added
"""
        for change in changes:
            new_entry += f"- {change}\n"

        if changelog.exists():
            existing = changelog.read_text()
            updated = new_entry + "\n" + existing
        else:
            updated = f"# Changelog\n\n{new_entry}"

        changelog.write_text(updated)
```

## Project Structure

```
project/
├── docs/                          # All documentation
│   ├── README.md
│   ├── decisions/                 # ADRs
│   ├── what-works/               # Success logs
│   ├── what-doesnt-work/         # Failure logs
│   └── guides/
├── .knowledge-base/              # RAG embeddings
├── notifications/
│   └── config.yaml
└── system-manager/
    ├── rag_system.py
    ├── outcome_tracker.py
    ├── notification_manager.py
    └── auto_docs.py
```

## Resources

The `resources/` directory contains:
- Documentation templates
- ADR templates
- RAG system configurations
- Notification templates
- Agent integration examples

## Scripts

The `scripts/` directory contains:
- `init-docs.sh` - Initialize documentation structure
- `update-rag.sh` - Update RAG knowledge base
- `query-docs.sh` - Query documentation via RAG
- `generate-report.sh` - Generate documentation reports

## Hooks

The `hooks/` directory contains:
- Post-commit documentation hooks
- Notification trigger hooks
- RAG update hooks

## Agents

The `agents/` directory contains:
- `doc-generator` - Auto-generate documentation
- `knowledge-indexer` - Index and update knowledge base
- `outcome-analyzer` - Analyze success/failure patterns
- `notification-router` - Route notifications intelligently

## Quick Start

```bash
# Initialize documentation structure
mkdir -p docs/{decisions,what-works,what-doesnt-work,guides}

# Set up RAG system
python -c "
from system_manager import DocumentationRAG
rag = DocumentationRAG('docs')
"

# Query documentation
python -c "
from system_manager import DocumentationRAG
rag = DocumentationRAG('docs')
answer = rag.query('How do we handle authentication?')
print(answer)
"

# Log successful approach
python -c "
from system_manager import OutcomeTracker
tracker = OutcomeTracker()
tracker.log_success(
    'Deployment Process',
    'Automated deployment using GitHub Actions',
    'DevOps',
    {'time_saved': '2 hours per deploy'}
)
"
```

## Integration with Other Skills

- Central skill for all documentation needs
- Integrates with `/data-reporter/` for activity documentation
- Works with `/automater/` for documenting automations
- Supports all skills by providing documentation framework

## Best Practices

1. **Document as you go** - Don't defer documentation
2. **Log failures** - They're as valuable as successes
3. **Keep it searchable** - Use consistent structure
4. **Update regularly** - Keep documentation current
5. **Use templates** - Ensure consistency
6. **Link related docs** - Create knowledge graph
7. **Version documentation** - Track changes over time
8. **Make it accessible** - Easy to find and read
9. **Automate when possible** - Reduce manual effort
10. **Review periodically** - Remove outdated content

## External Agent Integration Notes

This skill provides scaffolding for external agent integration. The user will configure:

1. Documentation generation agents
2. Knowledge management agents
3. Notification routing agents
4. Custom workflow agents

Scaffolding provides:
- Interface definitions
- Placeholder methods
- Integration points marked with TODO
- Example configurations

## Notes

- RAG system uses local embeddings (no API required)
- Notification channels are configurable
- External agent integration is scaffolded
- Documentation should be version controlled
- Keep documentation close to code
- Automate documentation updates
- Track what works AND what doesn't
- Use templates for consistency
