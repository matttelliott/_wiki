# Claude Desktop

Claude Desktop is the GUI application for interacting with Claude AI, providing a traditional chat interface as an alternative to [[claude-code]] (the CLI tool).

## Overview

Claude Desktop is Anthropic's desktop application that provides:
- Traditional chat window interface
- File upload and attachment support
- Visual conversation history
- Projects for organizing chats
- Native OS integration (macOS, Windows)

## Key Differences from Claude Code

| Aspect | Claude Desktop | [[claude-code]] |
|--------|---------------|----------------|
| **Interface** | GUI/Window | Terminal/CLI |
| **Primary Use** | Conversations, analysis | Active coding, file editing |
| **File Access** | Upload/attach only | Direct filesystem access |
| **Code Editing** | View/suggest only | Direct file modification |
| **Git Integration** | None | Full git operations |
| **Automation** | Limited | Full SDK/scripting |
| **Context** | Manual uploads | Automatic codebase context |
| **Tools** | Limited | Full tool suite |

## When to Use Claude Desktop

**Best for:**
- General conversations and Q&A
- Document analysis and review
- Learning and exploration
- Non-technical users
- Visual content work
- When you need conversation history

**Not ideal for:**
- Active software development
- File system operations
- Automated workflows
- Git operations
- Bulk file editing

## When to Use Claude Code Instead

**Choose [[claude-code]] when you need:**
- Direct file editing capabilities
- Git commit/push operations
- Running commands and scripts
- Filesystem navigation
- Automated development workflows
- Integration with existing terminal workflow

## Complementary Usage

Many developers use both tools:
- **Claude Desktop:** Planning, research, documentation review
- **Claude Code:** Implementation, debugging, file operations

## Installation

### Claude Desktop
- Download from Anthropic's website
- Native installers for macOS/Windows
- Requires account login

### Claude Code
```bash
npm install -g @anthropic-ai/claude-code
```

## Related

- [[claude-code]] - CLI alternative for development
- [[claude-cli]] - Understanding the terminology
- [[claude-code-interfaces]] - All ways to interact with Claude
- [[claude-mastery]] - Advanced Claude usage project