# AGENTS.md - Coding Agent Guide for BGG MCP

This document provides essential information for agentic coding agents working in the BGG MCP repository.

## Project Overview

BGG MCP is a Model Context Protocol (MCP) server that provides access to the BoardGameGeek API. It's implemented in Go and uses the GoGeek library for API interactions.

- **Language**: Go 1.23.0+ (toolchain go1.24.3)
- **Purpose**: MCP server for BoardGameGeek data access
- **Main Framework**: github.com/mark3labs/mcp-go
- **API Library**: github.com/kkjdaniel/gogeek/v2

## Operational Guides

For deployment and client configuration, start here:

- [AGENT_CONFIGURATION_GUIDE.md](/Users/nantasmac/projects/agentic/bgg-mcp/AGENT_CONFIGURATION_GUIDE.md) - Recommended setup patterns, including the macOS Docker host + Windows remote HTTP workflow

## Build Commands

```bash
# Build using Makefile (recommended)
make build          # Creates build/bgg-mcp binary
make clean          # Remove build artifacts
make all            # Clean and build

# Direct Go build
go build -o build/bgg-mcp

# Docker build
docker build -t bgg-mcp .

# Running
./build/bgg-mcp                           # STDIO mode (default)
./build/bgg-mcp -mode http -port 8080     # HTTP mode
```

## Testing

Currently no tests exist. When adding:

```bash
go test ./...                             # All tests
go test ./tools                           # Package tests
go test -run TestFunctionName ./tools     # Specific test
go test -v ./...                          # Verbose
go test -cover ./...                      # Coverage
```

## Linting

```bash
go fmt ./...                              # Format
go vet ./...                              # Vet
golangci-lint run                         # Comprehensive linting (if installed)
```

## Code Style Guidelines

### Import Organization

Three groups separated by blank lines: standard library, external packages, local packages

```go
import (
	"context"
	"fmt"

	"github.com/kkjdaniel/gogeek/v2"
	"github.com/mark3labs/mcp-go/mcp"
)
```

### Naming Conventions

- **Packages**: lowercase, single word (e.g., `tools`, `resources`, `prompts`)
- **Functions**: MixedCase for exported, camelCase for unexported
- **Variables**: camelCase for local, MixedCase for exported
- **Constants**: MixedCase (not ALL_CAPS)
- **Interfaces**: typically end with "-er" (e.g., `Handler`, `Reader`)

### Tool/Resource Factory Pattern

```go
func ToolName(client *gogeek.Client) (mcp.Tool, server.ToolHandlerFunc) {
	tool := mcp.NewTool("tool-name",
		mcp.WithDescription("Description"),
		mcp.WithString("param", mcp.Required()),
	)

	handler := func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		arguments := request.GetArguments()
		// Implementation
		return mcp.NewToolResultText("result"), nil
	}

	return tool, handler
}
```

### Error Handling

- Return errors as values, do not panic
- Use `fmt.Errorf` with `%v` or `%w` for error wrapping
- Return errors in tool results as text, not as error values:

```go
if err != nil {
	return mcp.NewToolResultText(fmt.Sprintf("Error: %v", err)), nil
}

// Validate required parameters
if param, ok := arguments["param"].(string); !ok || param == "" {
	return mcp.NewToolResultText("Parameter 'param' is required"), nil
}
```

### Type Assertions

Always use comma-ok idiom:

```go
if val, ok := arguments["key"].(string); ok {
	// use val
}
```

### Struct Definitions

Use JSON tags with snake_case:

```go
type EssentialGameInfo struct {
	ID           int      `json:"id"`
	Name         string   `json:"name"`
	Description  string   `json:"description"`
	Year         int      `json:"year"`
	Complexity   float64  `json:"complexity"`
	Categories   []string `json:"categories"`
	Mechanics    []string `json:"mechanics"`
}
```

### Parameter Handling

```go
arguments := request.GetArguments()

// String
if username, ok := arguments["username"].(string); ok && username != "" {
	// use username
}

// Number (comes as float64 from JSON)
limit := 30
if l, ok := arguments["limit"].(float64); ok {
	limit = int(l)
}

// Boolean
if owned, ok := arguments["owned"].(bool); ok {
	// use owned
}
```

### Context Usage

Always pass context as first parameter:

```go
handler := func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	// Use ctx for cancellation if making external calls
}
```

### JSON Handling

Always check for marshaling errors:

```go
out, err := json.Marshal(data)
if err != nil {
	return mcp.NewToolResultText(fmt.Sprintf("JSON encoding error: %v", err)), nil
}
return mcp.NewToolResultText(string(out)), nil
```

### Environment Variables

Common environment variables:
- `BGG_API_KEY`: API key for BGG authentication
- `BGG_COOKIE`: Cookie for BGG authentication (alternative)
- `BGG_USERNAME`: User's BGG username for "self" references
- `MCP_MODE`: Server mode ("stdio" or "http")
- `MCP_PORT`: HTTP server port

```go
if apiKey := os.Getenv("BGG_API_KEY"); apiKey != "" {
	// use apiKey
}
```

### Project Structure

```
bgg-mcp/
├── main.go              # Entry point, server initialization
├── tools/               # MCP tool implementations
├── resources/           # MCP resource implementations
├── prompts/             # MCP prompt templates
├── go.mod               # Go module definition
├── Makefile             # Build automation
└── Dockerfile           # Container build
```

### Best Practices

1. **Consistency**: Follow existing patterns
2. **Simplicity**: Keep functions focused and small
3. **Validation**: Always validate input parameters
4. **Error Messages**: Provide clear, actionable error messages
5. **Type Safety**: Use type assertions with comma-ok
6. **Resource Management**: Use defer for cleanup (e.g., closing response bodies)

### Adding New Tools

1. Create new file in `tools/` directory
2. Implement factory function returning `(mcp.Tool, server.ToolHandlerFunc)`
3. Define tool with `mcp.NewTool` and appropriate parameters
4. Implement handler with proper error handling
5. Register in `main.go`'s `createMCPServer` function
6. Update README.md with tool documentation

### Common Patterns

**Tool Registration** (in main.go):

```go
tool, handler := tools.ToolName(client)
s.AddTool(tool, handler)
```

**Resource Registration** (in main.go):

```go
resource, resourceHandler := resources.ResourceName(client)
s.AddResource(resource, resourceHandler)
```

**MCP Server Configuration**:

```go
s := server.NewMCPServer(
	"BGG MCP",
	"1.6.0",
	server.WithResourceCapabilities(true, true),
	server.WithPromptCapabilities(true),
	server.WithLogging(),
	server.WithRecovery(),
)
```

### External API Integration

- Use the gogeek client for BGG API calls
- Handle rate limiting (built into gogeek)
- Always check for errors from API calls
- Return meaningful error messages to users
