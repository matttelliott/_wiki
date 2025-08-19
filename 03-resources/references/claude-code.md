# Claude Code

Claude Code is Anthropic's official terminal-based coding assistant that helps developers build features, debug issues, and navigate codebases directly from the command line.

## Overview

Claude Code is an agentic coding tool designed to meet developers where they already work - in the terminal, with their existing tools and workflows. Unlike traditional chat interfaces or IDE plugins, Claude Code operates as a CLI tool that can directly interact with your codebase.

## Installation

```bash
npm install -g @anthropic-ai/claude-code
```

## Command

The CLI command is simply `claude` (not `claude-code` or `claude-cli`):

```bash
claude                    # Start interactive REPL
claude "query"           # Start with initial prompt
claude -p "query"        # Query via SDK and exit
```

## Key Features

- Build features from natural language descriptions
- Debug and fix code issues
- Navigate and understand large codebases
- Automate repetitive development tasks
- Direct file system access and code modification
- Git integration for commits and PRs

## Terminology

- **Claude Code** - The official product name
- **[[claude-cli]]** - Common informal term used to distinguish from [[claude-desktop]]
- **`claude`** - The actual CLI command

## Interfaces

Claude Code can be accessed through multiple interfaces:
- **CLI** - Primary interface via terminal
- **[[claude-code-interfaces#ide-integrations|IDE Integrations]]** - VS Code and JetBrains extensions
- **[[claude-code-interfaces#sdk|SDK]]** - TypeScript and Python libraries
- **[[claude-code-interfaces#github-actions|GitHub Actions]]** - CI/CD integration

## Related

- [[claude-cli]] - Understanding the terminology
- [[claude-code-interfaces]] - Different ways to interact with Claude Code
- [[claude-desktop]] - GUI alternative to Claude Code

## Documentation

Official documentation: https://docs.anthropic.com/en/docs/claude-code