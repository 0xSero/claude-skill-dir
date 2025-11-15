# MCP (Model Context Protocol) Builder Expert

Expert in building efficient and effective Model Context Protocol (MCP) servers. Specializes in MCP server development, tool design, resource management, prompt templates, and using tools like MCPorter for porting existing tools to MCP format. Based on Anthropic's MCP specifications and best practices.

## When to use this skill

- Building new MCP servers
- Porting existing tools to MCP format
- Designing MCP tools and resources
- Creating MCP prompt templates
- Optimizing MCP server performance
- Debugging MCP implementations
- Integrating MCPs with Claude Desktop or other clients
- Converting APIs to MCP servers
- Building domain-specific MCP servers

## Core Expertise

### MCP Fundamentals

#### What is MCP?
Model Context Protocol (MCP) is an open protocol that enables seamless integration between LLM applications and external data sources and tools. Think of it as a universal adapter for connecting AI assistants to various services.

#### Core Components
1. **MCP Servers** - Expose tools, resources, and prompts
2. **MCP Clients** - Applications that consume MCP servers (e.g., Claude Desktop)
3. **Tools** - Functions the AI can call
4. **Resources** - Data the AI can access
5. **Prompts** - Pre-defined prompt templates

### MCP Server Setup

#### Python MCP Server (Recommended)
```python
from mcp.server import Server, NotificationOptions
from mcp.server.models import InitializationOptions
import mcp.server.stdio
import mcp.types as types

# Create server instance
server = Server("my-mcp-server")

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """List available tools"""
    return [
        types.Tool(
            name="get_weather",
            description="Get weather for a location",
            inputSchema={
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City name"
                    }
                },
                "required": ["location"]
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(
    name: str,
    arguments: dict
) -> list[types.TextContent]:
    """Handle tool calls"""
    if name == "get_weather":
        location = arguments["location"]
        # Fetch weather data
        weather_data = fetch_weather(location)
        return [
            types.TextContent(
                type="text",
                text=f"Weather in {location}: {weather_data}"
            )
        ]
    else:
        raise ValueError(f"Unknown tool: {name}")

async def main():
    # Run server using stdio transport
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="my-mcp-server",
                server_version="0.1.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

#### TypeScript MCP Server
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  {
    name: "my-mcp-server",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "get_weather",
        description: "Get weather for a location",
        inputSchema: {
          type: "object",
          properties: {
            location: {
              type: "string",
              description: "City name",
            },
          },
          required: ["location"],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "get_weather") {
    const location = request.params.arguments.location;
    const weatherData = await fetchWeather(location);

    return {
      content: [
        {
          type: "text",
          text: `Weather in ${location}: ${weatherData}`,
        },
      ],
    };
  }

  throw new Error(`Unknown tool: ${request.params.name}`);
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Tool Design Best Practices

#### Good Tool Design
```python
@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="search_documents",
            description="Search through document database using semantic search. Returns relevant document excerpts with metadata.",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query in natural language"
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Maximum number of results (default: 5)",
                        "default": 5,
                        "minimum": 1,
                        "maximum": 20
                    },
                    "filter": {
                        "type": "object",
                        "description": "Optional filters",
                        "properties": {
                            "date_from": {"type": "string", "format": "date"},
                            "category": {"type": "string"}
                        }
                    }
                },
                "required": ["query"]
            }
        )
    ]
```

#### Tool Design Principles
1. **Clear Naming** - Use descriptive, action-oriented names
2. **Detailed Descriptions** - Explain what the tool does and when to use it
3. **Well-Defined Schema** - Use JSON Schema with descriptions, defaults, constraints
4. **Error Handling** - Return meaningful error messages
5. **Validation** - Validate inputs before processing
6. **Atomic Operations** - Each tool should do one thing well
7. **Idempotency** - Same inputs should give same outputs when possible

### Resources

#### Exposing Resources
```python
@server.list_resources()
async def handle_list_resources() -> list[types.Resource]:
    """List available resources"""
    return [
        types.Resource(
            uri="file:///docs/readme.md",
            name="Project README",
            description="Project documentation and setup guide",
            mimeType="text/markdown"
        ),
        types.Resource(
            uri="config://settings",
            name="Configuration",
            description="Current server configuration",
            mimeType="application/json"
        )
    ]

@server.read_resource()
async def handle_read_resource(uri: str) -> str:
    """Read resource content"""
    if uri == "file:///docs/readme.md":
        with open("README.md") as f:
            return f.read()
    elif uri == "config://settings":
        return json.dumps(get_config())
    else:
        raise ValueError(f"Unknown resource: {uri}")
```

#### Resource Best Practices
- Use meaningful URI schemes (file://, http://, custom://)
- Provide accurate MIME types
- Include rich descriptions
- Support resource templates for dynamic content
- Implement efficient caching when appropriate

### Prompts

#### Defining Prompt Templates
```python
@server.list_prompts()
async def handle_list_prompts() -> list[types.Prompt]:
    """List available prompts"""
    return [
        types.Prompt(
            name="code_review",
            description="Review code for best practices and potential issues",
            arguments=[
                types.PromptArgument(
                    name="language",
                    description="Programming language",
                    required=True
                ),
                types.PromptArgument(
                    name="code",
                    description="Code to review",
                    required=True
                )
            ]
        )
    ]

@server.get_prompt()
async def handle_get_prompt(
    name: str,
    arguments: dict
) -> types.GetPromptResult:
    """Get prompt with arguments filled in"""
    if name == "code_review":
        language = arguments["language"]
        code = arguments["code"]

        return types.GetPromptResult(
            messages=[
                types.PromptMessage(
                    role="user",
                    content=types.TextContent(
                        type="text",
                        text=f"Review this {language} code:\n\n```{language}\n{code}\n```\n\nProvide feedback on:\n1. Code quality\n2. Best practices\n3. Potential bugs\n4. Performance considerations"
                    )
                )
            ]
        )
```

### Using MCPorter

#### What is MCPorter?
MCPorter (https://github.com/steipete/mcporter) is a tool that helps convert existing APIs, CLIs, and tools into MCP servers.

#### Installation
```bash
# Clone MCPorter
git clone https://github.com/steipete/mcporter
cd mcporter

# Install dependencies
npm install

# Or use directly
npx mcporter convert --help
```

#### Converting OpenAPI to MCP
```bash
# Convert OpenAPI spec to MCP server
mcporter convert openapi \
  --input api-spec.yaml \
  --output ./mcp-server \
  --language python

# Generated structure:
# mcp-server/
# ├── server.py          # MCP server implementation
# ├── tools.py           # Tool definitions
# ├── requirements.txt   # Dependencies
# └── README.md          # Usage instructions
```

#### Converting CLI Tools to MCP
```bash
# Convert CLI tool to MCP
mcporter convert cli \
  --command "gh" \
  --subcommands "issue,pr,repo" \
  --output ./gh-mcp

# Generates MCP server that wraps GitHub CLI
```

### MCP Server Configuration

#### Claude Desktop Configuration
```json
// ~/Library/Application Support/Claude/claude_desktop_config.json (Mac)
// %APPDATA%\Claude\claude_desktop_config.json (Windows)
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["/path/to/server.py"]
    },
    "node-server": {
      "command": "node",
      "args": ["/path/to/server.js"]
    },
    "uv-server": {
      "command": "uv",
      "args": [
        "--directory",
        "/path/to/server",
        "run",
        "server.py"
      ]
    }
  }
}
```

### Project Structure

#### Python MCP Server
```
my-mcp-server/
├── pyproject.toml        # UV project config
├── README.md
├── src/
│   └── my_mcp_server/
│       ├── __init__.py
│       ├── server.py     # Main server
│       ├── tools.py      # Tool implementations
│       └── resources.py  # Resource handlers
├── tests/
│   └── test_server.py
└── .env.example
```

#### TypeScript MCP Server
```
my-mcp-server/
├── package.json
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts          # Main server
│   ├── tools.ts          # Tool implementations
│   └── resources.ts      # Resource handlers
└── dist/                 # Compiled output
```

### Testing MCP Servers

#### Using MCP Inspector
```bash
# Install MCP Inspector
npm install -g @modelcontextprotocol/inspector

# Test your server
mcp-inspector python server.py

# Or for Node
mcp-inspector node dist/index.js
```

#### Unit Tests
```python
import pytest
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

@pytest.mark.asyncio
async def test_tool_call():
    server_params = StdioServerParameters(
        command="python",
        args=["server.py"]
    )

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # List tools
            tools = await session.list_tools()
            assert len(tools.tools) > 0

            # Call tool
            result = await session.call_tool(
                "get_weather",
                {"location": "San Francisco"}
            )
            assert result.content[0].text
```

### Security Best Practices

#### Input Validation
```python
def validate_tool_input(tool_name: str, arguments: dict):
    """Validate tool inputs"""
    if tool_name == "execute_command":
        # Whitelist allowed commands
        allowed_commands = ["ls", "pwd", "date"]
        command = arguments.get("command", "").split()[0]

        if command not in allowed_commands:
            raise ValueError(f"Command not allowed: {command}")

    # Validate file paths
    if "path" in arguments:
        path = Path(arguments["path"]).resolve()
        allowed_dir = Path("/allowed/directory").resolve()

        if not path.is_relative_to(allowed_dir):
            raise ValueError("Path not allowed")
```

#### Rate Limiting
```python
from collections import defaultdict
from datetime import datetime, timedelta

class RateLimiter:
    def __init__(self, max_calls=10, period=60):
        self.max_calls = max_calls
        self.period = period
        self.calls = defaultdict(list)

    def check(self, key: str) -> bool:
        now = datetime.now()
        cutoff = now - timedelta(seconds=self.period)

        # Remove old calls
        self.calls[key] = [
            call_time for call_time in self.calls[key]
            if call_time > cutoff
        ]

        if len(self.calls[key]) >= self.max_calls:
            return False

        self.calls[key].append(now)
        return True

rate_limiter = RateLimiter(max_calls=10, period=60)

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict):
    if not rate_limiter.check("global"):
        raise Exception("Rate limit exceeded")

    # Process tool call
    ...
```

### Common MCP Patterns

#### Database MCP Server
```python
# Expose database queries as tools
tools = [
    Tool(
        name="query_users",
        description="Query user database",
        inputSchema={...}
    ),
    Tool(
        name="get_analytics",
        description="Get analytics data",
        inputSchema={...}
    )
]
```

#### API Wrapper MCP Server
```python
# Wrap external API
@server.call_tool()
async def handle_call_tool(name: str, arguments: dict):
    if name == "search_github":
        async with aiohttp.ClientSession() as session:
            async with session.get(
                "https://api.github.com/search/repositories",
                params={"q": arguments["query"]}
            ) as response:
                data = await response.json()
                return [types.TextContent(
                    type="text",
                    text=json.dumps(data, indent=2)
                )]
```

#### File System MCP Server
```python
# Safe file system access
@server.list_resources()
async def handle_list_resources():
    base_dir = Path("/safe/directory")
    files = []

    for file_path in base_dir.rglob("*"):
        if file_path.is_file():
            files.append(types.Resource(
                uri=f"file://{file_path}",
                name=file_path.name,
                mimeType=get_mime_type(file_path)
            ))

    return files
```

## Resources

The `resources/` directory contains:
- MCP server templates (Python, TypeScript)
- Common tool implementations
- Example OpenAPI specs for conversion
- Configuration examples
- Testing utilities

## Scripts

The `scripts/` directory contains:
- `create-mcp-server.sh` - Scaffold new MCP server
- `test-mcp-server.sh` - Test MCP server locally
- `convert-openapi.sh` - Convert OpenAPI to MCP using MCPorter
- `install-to-claude.sh` - Install MCP server to Claude Desktop

## Hooks

The `hooks/` directory contains:
- Pre-commit validation hooks
- Server health check hooks

## Agents

The `agents/` directory contains:
- `mcp-converter` - Convert APIs/CLIs to MCP
- `tool-optimizer` - Optimize tool definitions
- `schema-validator` - Validate JSON schemas

## Quick Start Guide

### 1. Create New MCP Server
```bash
# Using UV for Python
uv init my-mcp-server
cd my-mcp-server
uv add mcp

# Create server.py (see examples above)
```

### 2. Test Server
```bash
# Install inspector
npm install -g @modelcontextprotocol/inspector

# Test
mcp-inspector uv run server.py
```

### 3. Install to Claude Desktop
```bash
# Edit Claude config
code ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Add your server
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["--directory", "/path/to/my-mcp-server", "run", "server.py"]
    }
  }
}
```

### 4. Restart Claude Desktop
Server will be available in Claude!

## Integration with Other Skills

- Works with `/python-dev/` for Python MCP servers
- Complements `/automater/` for automation MCPs
- Integrates with `/system-manager/` for documentation
- Supports `/data-reporter/` for analytics MCPs

## Best Practices Checklist

- [ ] Clear, descriptive tool names
- [ ] Detailed tool descriptions with usage examples
- [ ] Complete JSON Schema with descriptions
- [ ] Input validation and sanitization
- [ ] Proper error handling with helpful messages
- [ ] Rate limiting for expensive operations
- [ ] Security checks for file/command access
- [ ] Comprehensive logging
- [ ] Unit tests for all tools
- [ ] Documentation with examples
- [ ] Version control for server code
- [ ] Configuration via environment variables

## Common Pitfalls

1. **Overly broad tools** - Break into smaller, focused tools
2. **Missing descriptions** - Always describe what tools do
3. **Poor error messages** - Return helpful, actionable errors
4. **No input validation** - Always validate before processing
5. **Synchronous operations** - Use async for I/O operations
6. **Hardcoded values** - Use environment variables
7. **No logging** - Add comprehensive logging for debugging

## Notes

- MCP is transport-agnostic (stdio, HTTP, etc.)
- Prefer async operations for better performance
- Test with MCP Inspector before deploying
- Keep tools focused and composable
- Document expected inputs and outputs
- Version your MCP servers
- Monitor usage and performance
- Follow security best practices
- Contribute to MCP ecosystem
