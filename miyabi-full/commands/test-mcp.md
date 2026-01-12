# Test MCP Tools

This command tests your MCP tool setup with the deployed Miyabi API.

## Usage
```
./claude test-mcp
```

## What it does:
1. Verifies Chrome DevTools MCP is configured
2. Tests navigation to the deployed API
3. Checks network response
4. Runs performance analysis

## Example Prompts:

### Test 1: Navigation
"Use Chrome DevTools MCP to navigate to https://miyabi-web-api-ycw7g3zkva-an.a.run.app/health and get the response"

### Test 2: Performance
"Start a performance trace on https://miyabi-web-api-ycw7g3zkva-an.a.run.app/health, wait 2 seconds, then end trace and analyze"

### Test 3: Network Inspection
"Navigate to https://miyabi-web-api-ycw7g3zkva-an.a.run.app/health and show me all network requests made"

### Test 4: Console Check
"Use Chrome DevTools to check the console for any errors on the deployed Miyabi API"

## MCP Tools Reference:
- `performance_start_trace` - Start recording
- `performance_end_trace` - Stop recording & analyze
- `navigate` - Go to URL
- `get_network_requests` - View requests
- `get_console_messages` - View console logs
- `inspect_dom` - Inspect elements
- `evaluate_js` - Run JavaScript
