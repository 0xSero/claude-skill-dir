# System & Documentation Manager with Mem-Layer

Expert in managing system state, documentation, and knowledge using mem-layer's graph-based memory system. Automatically tracks decisions, maintains context, monitors what works and what doesn't, and provides intelligent retrieval of project history and knowledge.

**Powered by mem-layer**: Graph-based memory management for organized, queryable system knowledge.

## When to use this skill

- Tracking project decisions and rationale
- Maintaining system context across sessions
- Recording what works and what doesn't
- Querying historical decisions and outcomes
- Building searchable knowledge graphs
- Feeding context to AI about past work
- Documenting architecture and design decisions
- Monitoring system state and changes
- Creating relationships between concepts
- Intelligent context retrieval

## Core Expertise

### Mem-Layer Integration

#### What is Mem-Layer?
Graph-based memory management system that stores knowledge as nodes (entities, notes) connected by edges (relationships). Perfect for:
- **Decision tracking** - Store architecture decisions as nodes
- **Context building** - Query related information via graph traversal
- **Outcome tracking** - Link decisions to their results
- **Knowledge organization** - Use scopes for different contexts
- **Intelligent retrieval** - Find relevant information through relationships

Repository: https://github.com/0xSero/mem-layer

#### Mem-Layer CLI Integration
```python
import subprocess
import json
from typing import List, Dict, Optional
from datetime import datetime

class MemLayerManager:
    """Manage system knowledge using mem-layer"""

    def __init__(self, scope: Optional[str] = None):
        """
        Initialize mem-layer manager

        Args:
            scope: Scope name (defaults to current project)
        """
        self.scope = scope
        self._ensure_initialized()

    def _ensure_initialized(self):
        """Ensure mem-layer scope is initialized"""
        try:
            # Check if scope exists
            result = subprocess.run(
                ["mem-layer", "scope", "list"],
                capture_output=True,
                text=True,
                check=False
            )

            if self.scope and self.scope not in result.stdout:
                # Initialize scope
                subprocess.run(
                    ["mem-layer", "init", "--scope", "project", "--name", self.scope],
                    check=True
                )
        except FileNotFoundError:
            raise RuntimeError(
                "mem-layer not installed. Install from: "
                "https://github.com/0xSero/mem-layer"
            )

    def add_decision(
        self,
        title: str,
        decision: str,
        rationale: str,
        alternatives: Optional[List[str]] = None,
        tags: Optional[List[str]] = None,
        importance: float = 0.8
    ) -> str:
        """
        Record an architectural or technical decision

        Returns:
            Node ID of the created decision
        """
        # Create decision content
        content = f"""DECISION: {title}

What: {decision}

Why: {rationale}"""

        if alternatives:
            content += f"\n\nAlternatives considered:\n"
            for alt in alternatives:
                content += f"- {alt}\n"

        # Add to mem-layer
        decision_tags = ["decision", "architecture"] + (tags or [])

        result = subprocess.run(
            [
                "mem-layer", "add", "entity",
                content,
                "--tags", ",".join(decision_tags),
                "--importance", str(importance)
            ] + (["--scope", self.scope] if self.scope else []),
            capture_output=True,
            text=True,
            check=True
        )

        # Extract node ID from output
        node_id = self._extract_node_id(result.stdout)

        return node_id

    def add_outcome(
        self,
        title: str,
        what_happened: str,
        worked: bool,
        lessons: Optional[str] = None,
        related_decision: Optional[str] = None,
        tags: Optional[List[str]] = None
    ) -> str:
        """
        Record what worked or didn't work

        Args:
            worked: True if successful, False if failed
            related_decision: Node ID of related decision
        """
        status = "✅ WORKED" if worked else "❌ DIDN'T WORK"

        content = f"""{status}: {title}

What happened: {what_happened}"""

        if lessons:
            content += f"\n\nLessons learned:\n{lessons}"

        outcome_tags = ["outcome", "worked" if worked else "failed"] + (tags or [])

        result = subprocess.run(
            [
                "mem-layer", "add", "note",
                content,
                "--tags", ",".join(outcome_tags),
                "--priority", "high" if not worked else "normal"
            ] + (["--scope", self.scope] if self.scope else []),
            capture_output=True,
            text=True,
            check=True
        )

        node_id = self._extract_node_id(result.stdout)

        # Link to related decision if provided
        if related_decision:
            self.relate(
                related_decision,
                node_id,
                "resulted_in"
            )

        return node_id

    def add_context(
        self,
        title: str,
        context: str,
        context_type: str = "session",
        tags: Optional[List[str]] = None
    ) -> str:
        """
        Add contextual information about work done

        Args:
            context_type: Type of context (session, deployment, feature, bugfix)
        """
        content = f"""{context_type.upper()}: {title}

{context}

Recorded: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""

        context_tags = ["context", context_type] + (tags or [])

        result = subprocess.run(
            [
                "mem-layer", "add", "note",
                content,
                "--tags", ",".join(context_tags)
            ] + (["--scope", self.scope] if self.scope else []),
            capture_output=True,
            text=True,
            check=True
        )

        return self._extract_node_id(result.stdout)

    def relate(
        self,
        source_id: str,
        target_id: str,
        relationship: str = "relates_to"
    ) -> str:
        """
        Create relationship between nodes

        Common relationships:
        - relates_to: General relation
        - resulted_in: Decision → Outcome
        - depends_on: Dependency
        - implements: Implementation of concept
        - supersedes: Replaces previous decision
        """
        result = subprocess.run(
            ["mem-layer", "relate", source_id, target_id, "--type", relationship],
            capture_output=True,
            text=True,
            check=True
        )

        return self._extract_node_id(result.stdout)

    def query_decisions(self, pattern: str = "*", limit: int = 20) -> List[Dict]:
        """Query decisions from memory"""
        return self._query_by_tag("decision", pattern, limit)

    def query_outcomes(
        self,
        worked: Optional[bool] = None,
        pattern: str = "*",
        limit: int = 20
    ) -> List[Dict]:
        """Query outcomes (what worked/didn't work)"""
        tag = "outcome"
        if worked is not None:
            tag = "worked" if worked else "failed"

        return self._query_by_tag(tag, pattern, limit)

    def query_context(
        self,
        context_type: Optional[str] = None,
        pattern: str = "*",
        limit: int = 20
    ) -> List[Dict]:
        """Query contextual information"""
        tag = context_type if context_type else "context"
        return self._query_by_tag(tag, pattern, limit)

    def search(self, text: str, limit: int = 20) -> List[Dict]:
        """Full-text search across all knowledge"""
        result = subprocess.run(
            [
                "mem-layer", "search",
                text,
                "--limit", str(limit)
            ] + (["--scope", self.scope] if self.scope else []),
            capture_output=True,
            text=True,
            check=True
        )

        return self._parse_search_results(result.stdout)

    def get_related(self, node_id: str, depth: int = 2) -> Dict:
        """Get node and its related nodes via graph traversal"""
        result = subprocess.run(
            ["mem-layer", "traverse", node_id, "--depth", str(depth)],
            capture_output=True,
            text=True,
            check=True
        )

        return self._parse_traversal_results(result.stdout)

    def get_stats(self) -> Dict:
        """Get graph statistics"""
        result = subprocess.run(
            ["mem-layer", "graph", "stats"]
            + (["--scope", self.scope] if self.scope else []),
            capture_output=True,
            text=True,
            check=True
        )

        return self._parse_stats(result.stdout)

    def provide_context(self, query: str, max_items: int = 5) -> str:
        """
        Provide relevant context for a query

        This is the key function for feeding context to AI
        """
        # Search for relevant information
        results = self.search(query, limit=max_items)

        if not results:
            return "No relevant context found in system memory."

        context = f"## Relevant System Context for: {query}\n\n"

        for i, item in enumerate(results, 1):
            context += f"### {i}. {item.get('type', 'Note')}\n"
            context += f"{item.get('content', '')}\n\n"

            # Add tags for additional context
            if item.get('tags'):
                context += f"*Tags: {', '.join(item['tags'])}*\n\n"

        return context

    def _query_by_tag(
        self,
        tag: str,
        pattern: str = "*",
        limit: int = 20
    ) -> List[Dict]:
        """Internal: Query nodes by tag"""
        # Use search with tag in query
        result = subprocess.run(
            [
                "mem-layer", "search",
                f"#{tag}",
                "--limit", str(limit)
            ] + (["--scope", self.scope] if self.scope else []),
            capture_output=True,
            text=True,
            check=True
        )

        return self._parse_search_results(result.stdout)

    def _extract_node_id(self, output: str) -> str:
        """Extract node ID from mem-layer output"""
        # Look for patterns like "Created entity: abc12345"
        import re
        match = re.search(r'Created \w+: ([a-f0-9]+)', output)
        if match:
            return match.group(1)

        match = re.search(r'relationship: ([a-f0-9]+)', output)
        if match:
            return match.group(1)

        # Fallback: return first 8-char hex string found
        match = re.search(r'([a-f0-9]{8})', output)
        if match:
            return match.group(1)

        return ""

    def _parse_search_results(self, output: str) -> List[Dict]:
        """Parse search results from mem-layer output"""
        # This is simplified - in reality you'd parse the table output
        # or use JSON export if available
        results = []

        # Basic parsing of table output
        lines = output.split('\n')
        for line in lines:
            if '│' in line and not line.startswith('│ ID'):
                parts = [p.strip() for p in line.split('│') if p.strip()]
                if len(parts) >= 3:
                    results.append({
                        'id': parts[0],
                        'type': parts[1] if len(parts) > 1 else 'note',
                        'content': parts[2] if len(parts) > 2 else '',
                        'tags': []
                    })

        return results

    def _parse_traversal_results(self, output: str) -> Dict:
        """Parse traversal results"""
        return {
            'nodes': self._parse_search_results(output),
            'raw_output': output
        }

    def _parse_stats(self, output: str) -> Dict:
        """Parse statistics output"""
        stats = {}
        lines = output.split('\n')

        for line in lines:
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip().lower().replace(' ', '_')
                value = value.strip()

                # Try to convert to number
                try:
                    value = int(value)
                except ValueError:
                    try:
                        value = float(value)
                    except ValueError:
                        pass

                stats[key] = value

        return stats


class MemLayerHelper:
    """High-level helper for common system-manager tasks"""

    def __init__(self, project_name: Optional[str] = None):
        from pathlib import Path

        # Use current directory name as project if not specified
        if not project_name:
            project_name = Path.cwd().name

        self.manager = MemLayerManager(scope=project_name)
        self.project = project_name

    def record_deployment(
        self,
        version: str,
        environment: str,
        changes: List[str],
        success: bool = True,
        notes: Optional[str] = None
    ) -> str:
        """Record a deployment"""
        title = f"Deployment {version} to {environment}"

        content = f"""Deployed version {version} to {environment}

Changes:
"""
        for change in changes:
            content += f"- {change}\n"

        if notes:
            content += f"\nNotes:\n{notes}"

        return self.manager.add_context(
            title,
            content,
            context_type="deployment",
            tags=["deployment", environment, version]
        )

    def record_bug_fix(
        self,
        bug_description: str,
        solution: str,
        root_cause: Optional[str] = None
    ) -> str:
        """Record a bug fix"""
        content = f"""Bug: {bug_description}

Solution: {solution}"""

        if root_cause:
            content += f"\n\nRoot cause: {root_cause}"

        return self.manager.add_outcome(
            f"Bug fix: {bug_description[:50]}",
            content,
            worked=True,
            tags=["bugfix"]
        )

    def record_feature(
        self,
        feature_name: str,
        description: str,
        implementation_notes: Optional[str] = None
    ) -> str:
        """Record a new feature"""
        content = f"""Feature: {feature_name}

{description}"""

        if implementation_notes:
            content += f"\n\nImplementation:\n{implementation_notes}"

        return self.manager.add_context(
            feature_name,
            content,
            context_type="feature",
            tags=["feature"]
        )

    def ask_system(self, question: str) -> str:
        """
        Ask a question and get context from system memory

        This is the key interface for AI to query history
        """
        return self.manager.provide_context(question)

    def whats_worked(self, area: Optional[str] = None) -> List[Dict]:
        """Get list of what's worked"""
        pattern = area if area else "*"
        return self.manager.query_outcomes(worked=True, pattern=pattern)

    def whats_failed(self, area: Optional[str] = None) -> List[Dict]:
        """Get list of what hasn't worked"""
        pattern = area if area else "*"
        return self.manager.query_outcomes(worked=False, pattern=pattern)

    def get_decisions(self, area: Optional[str] = None) -> List[Dict]:
        """Get architectural decisions"""
        pattern = area if area else "*"
        return self.manager.query_decisions(pattern=pattern)

    def session_summary(self, summary: str, key_changes: List[str]) -> str:
        """Record session summary"""
        content = f"""Session Summary

{summary}

Key changes:
"""
        for change in key_changes:
            content += f"- {change}\n"

        return self.manager.add_context(
            f"Session {datetime.now().strftime('%Y-%m-%d')}",
            content,
            context_type="session",
            tags=["session-summary"]
        )
```

### Automatic Context Feeding

#### Context Provider for AI Sessions
```python
class ContextProvider:
    """Automatically provide context to AI based on current work"""

    def __init__(self, project_name: Optional[str] = None):
        self.helper = MemLayerHelper(project_name)

    def get_context_for_file(self, filepath: str) -> str:
        """Get relevant context when working on a file"""
        # Search for mentions of this file
        context = self.helper.ask_system(filepath)

        # Add recent changes to this area
        recent = self.helper.manager.query_context(
            context_type="session",
            limit=5
        )

        if recent:
            context += "\n\n## Recent Work\n"
            for item in recent[:3]:
                context += f"- {item.get('content', '')[:100]}...\n"

        return context

    def get_context_for_feature(self, feature_name: str) -> str:
        """Get context for implementing a feature"""
        # Check if we've done something similar before
        context = self.helper.ask_system(feature_name)

        # Check what's worked in similar areas
        similar_successes = self.helper.whats_worked(feature_name)

        if similar_successes:
            context += "\n\n## Similar Successful Approaches\n"
            for success in similar_successes[:3]:
                context += f"- {success.get('content', '')[:150]}...\n"

        return context

    def get_context_for_bug(self, bug_description: str) -> str:
        """Get context for fixing a bug"""
        # Search for similar bugs
        context = self.helper.ask_system(bug_description)

        # Look for related bug fixes
        bug_fixes = self.helper.manager.search(
            f"bug {bug_description}",
            limit=5
        )

        if bug_fixes:
            context += "\n\n## Related Bug Fixes\n"
            for fix in bug_fixes:
                context += f"- {fix.get('content', '')[:150]}...\n"

        return context

    def get_architectural_context(self, topic: str) -> str:
        """Get architectural decisions related to a topic"""
        decisions = self.helper.get_decisions(topic)

        context = f"## Architectural Decisions: {topic}\n\n"

        for decision in decisions:
            context += f"### Decision\n"
            context += f"{decision.get('content', '')}\n\n"

        return context
```

### CLI Integration

#### Command-line Interface for Quick Operations
```python
#!/usr/bin/env python3
"""
system-manager CLI - Quick access to system management functions
"""

import click
from system_manager import MemLayerHelper, ContextProvider

@click.group()
def cli():
    """System Manager - Track decisions, context, and outcomes"""
    pass

@cli.command()
@click.argument('title')
@click.option('--decision', required=True, help='The decision made')
@click.option('--why', required=True, help='Rationale for decision')
@click.option('--alt', multiple=True, help='Alternatives considered')
def decide(title, decision, why, alt):
    """Record a decision"""
    helper = MemLayerHelper()
    node_id = helper.manager.add_decision(
        title=title,
        decision=decision,
        rationale=why,
        alternatives=list(alt) if alt else None
    )
    click.echo(f"✓ Decision recorded: {node_id}")

@cli.command()
@click.argument('title')
@click.option('--what', required=True, help='What happened')
@click.option('--worked/--failed', default=True, help='Did it work?')
@click.option('--lessons', help='Lessons learned')
def outcome(title, what, worked, lessons):
    """Record an outcome (what worked or didn't)"""
    helper = MemLayerHelper()
    node_id = helper.manager.add_outcome(
        title=title,
        what_happened=what,
        worked=worked,
        lessons=lessons
    )
    status = "✓" if worked else "✗"
    click.echo(f"{status} Outcome recorded: {node_id}")

@cli.command()
@click.argument('question')
def ask(question):
    """Ask system for context"""
    provider = ContextProvider()
    context = provider.helper.ask_system(question)
    click.echo(context)

@cli.command()
@click.option('--area', help='Filter by area')
def worked(area):
    """Show what's worked"""
    helper = MemLayerHelper()
    results = helper.whats_worked(area)

    click.echo("\n✅ What's Worked:\n")
    for item in results:
        click.echo(f"- {item.get('content', '')[:100]}")

@cli.command()
@click.option('--area', help='Filter by area')
def failed(area):
    """Show what hasn't worked"""
    helper = MemLayerHelper()
    results = helper.whats_failed(area)

    click.echo("\n❌ What Hasn't Worked:\n")
    for item in results:
        click.echo(f"- {item.get('content', '')[:100]}")

@cli.command()
def stats():
    """Show system statistics"""
    helper = MemLayerHelper()
    stats = helper.manager.get_stats()

    click.echo("\n📊 System Stats:\n")
    for key, value in stats.items():
        click.echo(f"{key}: {value}")

if __name__ == '__main__':
    cli()
```

### Usage Examples

#### Example 1: Recording a Decision
```python
from system_manager import MemLayerHelper

helper = MemLayerHelper("my-project")

# Record architectural decision
decision_id = helper.manager.add_decision(
    title="Database Choice",
    decision="Use PostgreSQL for primary database",
    rationale="Need ACID compliance and complex querying",
    alternatives=[
        "MongoDB - Rejected: Need strong consistency",
        "SQLite - Rejected: Need multi-user support"
    ],
    tags=["database", "architecture"]
)

# Later, record how it went
helper.manager.add_outcome(
    title="PostgreSQL performance",
    what_happened="Query performance excellent for our use case",
    worked=True,
    lessons="Proper indexing crucial for complex joins",
    related_decision=decision_id
)
```

#### Example 2: Getting Context for AI
```python
from system_manager import ContextProvider

provider = ContextProvider("my-project")

# When starting work on authentication
context = provider.get_architectural_context("authentication")
print(context)
# AI now has all past decisions about auth!

# When fixing a bug
bug_context = provider.get_context_for_bug("login timeout")
print(bug_context)
# Shows related bug fixes and decisions
```

#### Example 3: Session Management
```python
# At start of session, get context
helper = MemLayerHelper()
recent_decisions = helper.get_decisions()

# Do work...

# At end of session, record summary
helper.session_summary(
    "Implemented user authentication",
    key_changes=[
        "Added JWT token generation",
        "Implemented refresh token flow",
        "Added rate limiting to login endpoint"
    ]
)
```

#### Example 4: CLI Usage
```bash
# Record a decision
system-manager decide "API Authentication" \
  --decision "Use JWT with refresh tokens" \
  --why "Stateless, scalable, industry standard" \
  --alt "Session cookies - less flexible" \
  --alt "OAuth only - adds complexity"

# Record what worked
system-manager outcome "JWT Implementation" \
  --what "JWT auth working perfectly, easy to scale" \
  --worked \
  --lessons "Remember to set proper expiration times"

# Ask for context
system-manager ask "How did we handle authentication?"

# See what's worked
system-manager worked --area authentication

# Get stats
system-manager stats
```

## Integration Points

### With Other Skills

**`/data-reporter/`** - Activity tracking feeds into mem-layer
```python
# data-reporter records activities
# system-manager converts them to knowledge

from data_reporter import ActivityTracker
from system_manager import MemLayerHelper

tracker = ActivityTracker()
helper = MemLayerHelper()

# At session end
summary = tracker.get_session_summary()
helper.session_summary(
    f"Session: {summary['duration_minutes']:.0f} minutes",
    [f"Commands: {summary['total_commands']}",
     f"Files: {summary['total_files']}"]
)
```

**`/automater/`** - Automation decisions tracked
```python
# When creating automation
helper.manager.add_decision(
    title="Automate deployment",
    decision="Use GitHub Actions for CI/CD",
    rationale="Free for public repos, good integration",
    tags=["automation", "cicd"]
)
```

**`/cleaner/`** - Code quality outcomes tracked
```python
# After cleanup
helper.manager.add_outcome(
    title="Removed any types from codebase",
    what_happened="Type safety improved, caught 5 bugs",
    worked=True,
    lessons="TypeScript strict mode catches issues early",
    tags=["code-quality", "typescript"]
)
```

## Best Practices

1. **Record decisions immediately** - Don't wait
2. **Always include rationale** - Future you will thank you
3. **Track failures** - They're learning opportunities
4. **Link related nodes** - Build the knowledge graph
5. **Use consistent tags** - Makes searching easier
6. **Query before deciding** - Check if you've solved this before
7. **Regular reviews** - Query old decisions to see if they still make sense
8. **Feed context to AI** - Use `ask_system()` liberally

## Quick Start

```bash
# Install mem-layer
git clone https://github.com/0xSero/mem-layer
cd mem-layer
pip install -e .

# Initialize for project
mem-layer init --scope project --name my-project

# Start using system-manager
python
>>> from system_manager import MemLayerHelper
>>> helper = MemLayerHelper("my-project")
>>> helper.manager.add_decision(
...     "Use mem-layer for knowledge management",
...     "Graph-based, queryable, perfect for context",
...     "Keeps system organized and provides AI context"
... )
```

## Notes

- Mem-layer stores everything in a graph database
- Scopes keep projects separated
- Queries use graph traversal for related information
- Perfect for building AI context
- Searchable, queryable, organized
- Tracks relationships between concepts
- No more lost decisions or forgotten context
- System stays organized automatically
