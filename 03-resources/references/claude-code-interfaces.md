# Claude Code Interfaces

Multiple ways to interact with [[claude-code]] beyond the standard CLI, each suited for different workflows and use cases.

## CLI (Primary Interface)

The command-line interface is the primary way to use Claude Code:

```bash
claude                    # Interactive REPL
claude "query"           # Single query with initial prompt  
claude -p "query"        # Query via SDK and exit
```

### Features
- Direct terminal integration
- File system access
- Git operations
- Background processes
- Full tool availability

## IDE Integrations

### VS Code Extension
- **Installation:** Run `claude` in VS Code's integrated terminal
- **Quick Launch:** Keyboard shortcuts for instant access
- **Features:**
  - Diff viewing directly in editor
  - Automatic selection/tab context sharing
  - File reference shortcuts
  - Diagnostic error sharing
- **Compatible Forks:** Cursor, Windsurf, VSCodium

### JetBrains Plugin
- **Supported IDEs:** IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand
- **Installation:** Via JetBrains Marketplace or auto-install
- **Features:** Similar to VS Code extension

## SDK

Programmatic access for building applications and automations:

### TypeScript SDK
```typescript
import { query } from '@anthropic-ai/claude-code';

const response = query('explain this code');
for await (const chunk of response) {
  console.log(chunk);
}
```

### Python SDK
```python
from claude_code import ClaudeSDKClient

client = ClaudeSDKClient()
response = client.query("explain this code")
for chunk in response:
    print(chunk)
```

### SDK Features
- Custom system prompts
- Multi-turn conversations
- JSON output formats
- Tool and permission configurations
- Streaming responses

## GitHub Actions

CI/CD integration for automated workflows:

```yaml
- name: Code Review with Claude
  uses: anthropic/claude-code-action@v1
  with:
    prompt: "Review this PR for security issues"
```

## MCP (Model Context Protocol)

Advanced integration through custom MCP servers:
- Custom tool creation
- External service integration
- Database connections
- API gateways

See [[claude-mastery]] project for MCP development details.

## Comparison Table

| Interface | Best For | Access Type | Context Management |
|-----------|----------|-------------|-------------------|
| CLI | General development | Direct | Manual |
| IDE | In-editor workflow | Extension | Automatic |
| SDK | Automation/Apps | Programmatic | Custom |
| GitHub Actions | CI/CD | Workflow | PR/Commit |
| MCP | Custom tools | Server | Extended |

## Choosing an Interface

- **Daily coding:** IDE integration for seamless workflow
- **Quick tasks:** CLI for direct access
- **Automation:** SDK for scripting and apps
- **CI/CD:** GitHub Actions for automated checks
- **Custom tools:** MCP for specialized integrations

## Related

- [[claude-code]] - Main documentation
- [[claude-cli]] - CLI terminology
- [[claude-desktop]] - GUI alternative
- [[claude-mastery]] - Advanced usage project