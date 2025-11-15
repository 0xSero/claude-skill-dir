# Activity & Data Reporter with Mem-Layer

Expert in tracking, analyzing, and reporting on user activities and system data. Integrates with mem-layer (https://github.com/0xSero/mem-layer) for persistent memory and activity tracking. Provides insights into work patterns, productivity metrics, and system usage.

## When to use this skill

- Tracking user activities and workflows
- Analyzing productivity patterns
- Recording session data
- Generating activity reports
- Monitoring system usage
- Creating activity timelines
- Analyzing work habits
- Providing productivity insights
- Tracking project time allocation
- Building historical activity database

## Core Expertise

### Mem-Layer Integration

#### What is Mem-Layer?
Mem-layer is a persistent memory system for tracking and storing user activities, decisions, and context. It provides a foundation for building intelligent activity tracking and recall systems.

Repository: https://github.com/0xSero/mem-layer

#### Scaffolding for Integration
```python
# NOTE: This is scaffolding - user will configure mem-layer integration

class MemLayerClient:
    """
    Scaffold for mem-layer integration.
    User will configure actual mem-layer connection.
    """

    def __init__(self, config_path: str = None):
        """
        Initialize mem-layer client
        Config will be set up by user with actual mem-layer instance
        """
        self.config_path = config_path or os.getenv("MEMLAYER_CONFIG")
        self.connected = False
        # User will add actual initialization

    async def store_activity(self, activity_data: dict):
        """
        Store activity in mem-layer
        User will implement actual storage logic
        """
        # Placeholder for mem-layer storage
        print(f"[MEM-LAYER] Would store: {activity_data}")
        # TODO: Actual mem-layer integration

    async def query_activities(self, query: dict):
        """
        Query historical activities from mem-layer
        User will implement actual query logic
        """
        # Placeholder for mem-layer queries
        print(f"[MEM-LAYER] Would query: {query}")
        # TODO: Actual mem-layer integration

    async def get_context(self, session_id: str):
        """
        Retrieve context for a session
        """
        # TODO: Implement with actual mem-layer
        pass
```

### Activity Tracking

#### Session Tracking
```python
from datetime import datetime
from typing import Dict, List
import json

class ActivityTracker:
    """Track user activities during sessions"""

    def __init__(self):
        self.current_session = {
            "session_id": self.generate_session_id(),
            "start_time": datetime.now().isoformat(),
            "activities": [],
            "commands": [],
            "files_accessed": [],
            "projects": set()
        }

    def track_command(self, command: str, cwd: str, exit_code: int):
        """Track command execution"""
        activity = {
            "type": "command",
            "timestamp": datetime.now().isoformat(),
            "command": command,
            "directory": cwd,
            "exit_code": exit_code
        }
        self.current_session["commands"].append(activity)

        # Extract project context
        project = self.extract_project(cwd)
        if project:
            self.current_session["projects"].add(project)

    def track_file_access(self, filepath: str, operation: str):
        """Track file operations"""
        activity = {
            "type": "file_access",
            "timestamp": datetime.now().isoformat(),
            "file": filepath,
            "operation": operation  # read, write, edit
        }
        self.current_session["files_accessed"].append(activity)

    def track_custom_activity(self, activity_type: str, data: dict):
        """Track custom activities"""
        activity = {
            "type": activity_type,
            "timestamp": datetime.now().isoformat(),
            **data
        }
        self.current_session["activities"].append(activity)

    def get_session_summary(self) -> dict:
        """Get summary of current session"""
        duration = datetime.now() - datetime.fromisoformat(
            self.current_session["start_time"]
        )

        return {
            "session_id": self.current_session["session_id"],
            "duration_minutes": duration.total_seconds() / 60,
            "total_commands": len(self.current_session["commands"]),
            "total_files": len(self.current_session["files_accessed"]),
            "projects": list(self.current_session["projects"]),
            "activities_count": len(self.current_session["activities"])
        }

    @staticmethod
    def generate_session_id() -> str:
        """Generate unique session ID"""
        from uuid import uuid4
        return f"session-{datetime.now():%Y%m%d-%H%M%S}-{uuid4().hex[:8]}"

    @staticmethod
    def extract_project(path: str) -> str:
        """Extract project name from path"""
        # Simple heuristic - look for .git directory
        from pathlib import Path
        current = Path(path)

        while current != current.parent:
            if (current / ".git").exists():
                return current.name
            current = current.parent

        return None
```

### Activity Analysis

#### Pattern Detection
```python
class ActivityAnalyzer:
    """Analyze activity patterns"""

    def analyze_command_patterns(self, sessions: List[dict]) -> dict:
        """Analyze common command patterns"""
        from collections import Counter

        all_commands = []
        for session in sessions:
            all_commands.extend([
                cmd["command"].split()[0]  # Get base command
                for cmd in session.get("commands", [])
            ])

        most_common = Counter(all_commands).most_common(10)

        return {
            "most_used_commands": [
                {"command": cmd, "count": count}
                for cmd, count in most_common
            ],
            "total_commands": len(all_commands),
            "unique_commands": len(set(all_commands))
        }

    def analyze_work_hours(self, sessions: List[dict]) -> dict:
        """Analyze work hour patterns"""
        from collections import defaultdict

        hours_activity = defaultdict(int)

        for session in sessions:
            start_time = datetime.fromisoformat(session["start_time"])
            hour = start_time.hour
            hours_activity[hour] += 1

        # Find peak hours
        peak_hours = sorted(
            hours_activity.items(),
            key=lambda x: x[1],
            reverse=True
        )[:3]

        return {
            "peak_hours": [
                {"hour": f"{hour:02d}:00", "sessions": count}
                for hour, count in peak_hours
            ],
            "hourly_distribution": dict(hours_activity)
        }

    def analyze_project_time(self, sessions: List[dict]) -> dict:
        """Analyze time spent on projects"""
        from collections import defaultdict

        project_time = defaultdict(float)

        for session in sessions:
            duration = session.get("duration_minutes", 0)
            for project in session.get("projects", []):
                project_time[project] += duration

        # Sort by time spent
        sorted_projects = sorted(
            project_time.items(),
            key=lambda x: x[1],
            reverse=True
        )

        return {
            "projects": [
                {
                    "name": project,
                    "time_minutes": time,
                    "time_hours": time / 60
                }
                for project, time in sorted_projects
            ]
        }

    def detect_repetitive_tasks(self, sessions: List[dict]) -> List[dict]:
        """Detect repetitive command sequences"""
        from collections import Counter

        # Find command sequences (3 commands in a row)
        sequences = []

        for session in sessions:
            commands = [
                cmd["command"]
                for cmd in session.get("commands", [])
            ]

            for i in range(len(commands) - 2):
                seq = tuple(commands[i:i+3])
                sequences.append(seq)

        # Find repeated sequences
        sequence_counts = Counter(sequences)
        repetitive = [
            {
                "sequence": list(seq),
                "count": count,
                "automation_candidate": count >= 5
            }
            for seq, count in sequence_counts.items()
            if count >= 3
        ]

        return sorted(repetitive, key=lambda x: x["count"], reverse=True)
```

### Reporting

#### Activity Report Generator
```python
class ReportGenerator:
    """Generate activity reports"""

    def generate_daily_report(self, sessions: List[dict]) -> str:
        """Generate daily activity report"""
        analyzer = ActivityAnalyzer()

        total_time = sum(s.get("duration_minutes", 0) for s in sessions)
        total_commands = sum(len(s.get("commands", [])) for s in sessions)
        unique_projects = set()
        for s in sessions:
            unique_projects.update(s.get("projects", []))

        command_patterns = analyzer.analyze_command_patterns(sessions)
        project_time = analyzer.analyze_project_time(sessions)

        report = f"""
# Daily Activity Report
Date: {datetime.now():%Y-%m-%d}

## Summary
- Total active time: {total_time:.1f} minutes ({total_time/60:.1f} hours)
- Number of sessions: {len(sessions)}
- Total commands executed: {total_commands}
- Projects worked on: {len(unique_projects)}

## Projects
"""

        for proj in project_time["projects"][:5]:
            report += f"- {proj['name']}: {proj['time_hours']:.1f} hours\n"

        report += "\n## Most Used Commands\n"
        for cmd in command_patterns["most_used_commands"][:5]:
            report += f"- {cmd['command']}: {cmd['count']} times\n"

        return report

    def generate_weekly_report(self, sessions: List[dict]) -> str:
        """Generate weekly activity report"""
        analyzer = ActivityAnalyzer()

        total_time = sum(s.get("duration_minutes", 0) for s in sessions)

        # Group by day
        from collections import defaultdict
        daily_time = defaultdict(float)

        for session in sessions:
            start_time = datetime.fromisoformat(session["start_time"])
            day = start_time.date().isoformat()
            daily_time[day] += session.get("duration_minutes", 0)

        project_time = analyzer.analyze_project_time(sessions)
        repetitive_tasks = analyzer.detect_repetitive_tasks(sessions)

        report = f"""
# Weekly Activity Report
Week ending: {datetime.now():%Y-%m-%d}

## Weekly Summary
- Total active time: {total_time/60:.1f} hours
- Average per day: {total_time/60/7:.1f} hours
- Number of sessions: {len(sessions)}

## Daily Breakdown
"""

        for day, minutes in sorted(daily_time.items()):
            report += f"- {day}: {minutes/60:.1f} hours\n"

        report += "\n## Top Projects\n"
        for proj in project_time["projects"][:10]:
            report += f"- {proj['name']}: {proj['time_hours']:.1f} hours\n"

        if repetitive_tasks:
            report += "\n## Automation Opportunities\n"
            report += "These command sequences are repeated and could be automated:\n\n"
            for task in repetitive_tasks[:5]:
                report += f"- Repeated {task['count']} times:\n"
                report += f"  ```\n"
                for cmd in task['sequence']:
                    report += f"  {cmd}\n"
                report += f"  ```\n"

        return report
```

### Data Storage

#### Local Storage (before mem-layer integration)
```python
import json
from pathlib import Path

class ActivityStorage:
    """Store activity data locally"""

    def __init__(self, data_dir: str = "~/.activity-tracker"):
        self.data_dir = Path(data_dir).expanduser()
        self.data_dir.mkdir(parents=True, exist_ok=True)

    def save_session(self, session: dict):
        """Save session data"""
        session_id = session["session_id"]
        filepath = self.data_dir / f"{session_id}.json"

        with open(filepath, 'w') as f:
            json.dump(session, f, indent=2)

    def load_sessions(
        self,
        start_date: datetime = None,
        end_date: datetime = None
    ) -> List[dict]:
        """Load sessions within date range"""
        sessions = []

        for filepath in self.data_dir.glob("session-*.json"):
            with open(filepath) as f:
                session = json.load(f)

            session_date = datetime.fromisoformat(session["start_time"])

            # Filter by date range
            if start_date and session_date < start_date:
                continue
            if end_date and session_date > end_date:
                continue

            sessions.append(session)

        return sorted(sessions, key=lambda s: s["start_time"])

    def get_recent_sessions(self, days: int = 7) -> List[dict]:
        """Get sessions from last N days"""
        from datetime import timedelta

        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)

        return self.load_sessions(start_date, end_date)
```

### Visualization

#### Activity Visualization
```python
def visualize_activity(sessions: List[dict]):
    """Visualize activity data (requires matplotlib)"""
    try:
        import matplotlib.pyplot as plt
        from collections import Counter

        # Command frequency
        all_commands = []
        for session in sessions:
            all_commands.extend([
                cmd["command"].split()[0]
                for cmd in session.get("commands", [])
            ])

        command_counts = Counter(all_commands).most_common(10)
        commands, counts = zip(*command_counts)

        plt.figure(figsize=(10, 6))
        plt.bar(commands, counts)
        plt.xlabel('Command')
        plt.ylabel('Frequency')
        plt.title('Most Used Commands')
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig('command_frequency.png')
        print("Chart saved to command_frequency.png")

    except ImportError:
        print("matplotlib not installed - skipping visualization")
```

## Project Structure

```
data-reporter/
├── pyproject.toml
├── src/
│   └── data_reporter/
│       ├── __init__.py
│       ├── tracker.py          # Activity tracking
│       ├── analyzer.py         # Pattern analysis
│       ├── reporter.py         # Report generation
│       ├── storage.py          # Data storage
│       ├── memlayer.py         # Mem-layer integration (scaffold)
│       └── cli.py              # Command-line interface
├── data/
│   └── sessions/               # Stored session data
├── reports/
│   └── generated/              # Generated reports
└── tests/
    └── test_tracker.py
```

## Resources

The `resources/` directory contains:
- Report templates
- Mem-layer configuration examples
- Activity tracking patterns
- Analysis notebooks

## Scripts

The `scripts/` directory contains:
- `start-tracking.sh` - Start activity tracking
- `generate-report.sh` - Generate activity reports
- `analyze-patterns.sh` - Analyze activity patterns
- `export-data.sh` - Export activity data

## Hooks

The `hooks/` directory contains:
- Session start/end hooks
- Activity capture hooks
- Report generation hooks

## Agents

The `agents/` directory contains:
- `pattern-detector` - Detect activity patterns
- `productivity-analyzer` - Analyze productivity metrics
- `report-generator` - Generate custom reports
- `automation-suggester` - Suggest automation opportunities

## Mem-Layer Integration Notes

**IMPORTANT**: This skill provides scaffolding for mem-layer integration. The user needs to:

1. Configure mem-layer instance (github.com/0xSero/mem-layer)
2. Set up connection credentials
3. Implement actual storage/retrieval methods
4. Configure data synchronization

The scaffolding in this skill provides:
- Interface definitions for mem-layer
- Placeholder methods to be implemented
- Data structures compatible with mem-layer
- Integration points clearly marked with TODO

## Quick Start

```bash
# Initialize tracker
from data_reporter import ActivityTracker

tracker = ActivityTracker()

# Track activities
tracker.track_command("git status", "/project", 0)
tracker.track_file_access("/project/file.py", "edit")

# Get session summary
summary = tracker.get_session_summary()
print(summary)

# Save session
from data_reporter import ActivityStorage

storage = ActivityStorage()
storage.save_session(tracker.current_session)

# Generate report
from data_reporter import ReportGenerator

sessions = storage.get_recent_sessions(days=7)
report = ReportGenerator().generate_weekly_report(sessions)
print(report)
```

## Integration with Other Skills

- Works with `/system-manager/` for activity documentation
- Complements `/automater/` for detecting automation needs
- Integrates with `/python-dev/` for tool development
- Supports all skills by tracking their usage patterns

## Privacy & Data Handling

- All data stored locally by default
- User controls what is tracked
- Can exclude sensitive directories/files
- Export capabilities for data portability
- Clear data retention policies
- Mem-layer integration optional

## Future Enhancements (User to Implement)

- Real-time mem-layer synchronization
- Advanced pattern recognition with ML
- Cross-device activity aggregation
- Predictive analytics
- Custom dashboards
- Integration with time tracking tools

## Notes

- Mem-layer integration is scaffolded - user will complete
- Activity tracking respects privacy
- Data stored locally unless configured otherwise
- Reports can be customized
- Useful for productivity analysis
- Helps identify automation opportunities
- Integrates with workflow optimization
