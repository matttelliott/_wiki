# AI Agent Instructions

## Overview
This wiki is designed to work seamlessly with AI agents, particularly Claude. The system uses specialized subagents for different knowledge management tasks, ensuring consistent, high-quality note creation and organization.

## For AI Agents

### Primary Directive
**ALWAYS proactively use the appropriate subagent from `.claude/agents/` based on the task context. Do not wait for explicit requests.**

### Agent Selection Guide

| Task Type | Use Agent | Location |
|-----------|-----------|----------|
| Creating any note | `wiki-note-creator` | `.claude/agents/wiki-note-creator.md` |
| Organizing content | `knowledge-organizer` | `.claude/agents/knowledge-organizer.md` |
| Daily notes/journals | `daily-note-assistant` | `.claude/agents/daily-note-assistant.md` |
| Project documentation | `project-manager` | `.claude/agents/project-manager.md` |
| Processing literature | `literature-processor` | `.claude/agents/literature-processor.md` |
| Capturing ideas | `idea-capturer` | `.claude/agents/idea-capturer.md` |
| Complex/vague requests | `prompt-engineer-expert` | Built-in Claude agent |

### Wiki Conventions

#### File Structure
```
_wiki/
├── 00-Inbox/           # All new captures start here
├── 01-Projects/        # Project documentation
│   ├── _Active/       # Current projects
│   └── _Completed/    # Archived projects
├── 02-Areas/          # Ongoing responsibilities
│   ├── Learning/      # Educational materials
│   ├── Personal/      # Personal development
│   └── Professional/  # Work-related areas
├── 03-Resources/      # Reference materials
│   ├── Archives/      # Outdated but preserved
│   ├── Literature/    # Books, articles, papers
│   └── References/    # Quick reference materials
├── 04-Daily/          # Daily notes (YYYY-MM-DD.md)
├── 05-Templates/      # Reusable note templates
├── 06-Attachments/    # Images, PDFs, other files
└── _System/          # System docs and configs
```

#### Formatting Standards
- **Links:** Use `[[wikilinks]]` for internal connections
- **Tags:** Use `#tag` format, hierarchical with `/` (e.g., `#project/active`)
- **Headings:** Markdown format (`#` for title, `##` for sections)
- **Tasks:** Checkbox format `- [ ]` for todos
- **Dates:** ISO format `YYYY-MM-DD`
- **Names:** Title Case for note names

#### Frontmatter Requirements
Every note should include YAML frontmatter:
```yaml
---
date: YYYY-MM-DD
tags: [relevant, tags]
type: [note-type]
status: [draft/active/complete]
---
```

### Processing Workflows

#### New Information Capture
1. Create in `00-Inbox/` first
2. Process within 24-48 hours
3. Move to appropriate location
4. Establish connections
5. Update indexes

#### Daily Workflow
1. Morning: Create daily note from template
2. Throughout: Capture in appropriate format
3. Evening: Process and reflect
4. Weekly: Review and organize

#### Project Management
1. Define clear outcomes
2. Break into milestones
3. Track next actions
4. Regular status updates
5. Archive when complete

### Quality Standards

#### Note Quality
- **Atomic:** One idea per note
- **Self-contained:** Understandable standalone
- **Connected:** Linked to related notes
- **Evergreen:** Timeless when possible
- **Clear:** Written for future self

#### Organization Quality
- **Consistent:** Follow established patterns
- **Discoverable:** Proper tags and links
- **Maintained:** Regular reviews and updates
- **Documented:** Clear purpose and context
- **Accessible:** Logical structure

## For Human Users

### Getting Started
1. Review the file structure and understand PARA method
2. Check templates in `05-Templates/` for consistency
3. Start with daily notes for regular capture
4. Process inbox regularly (weekly minimum)
5. Build connections between notes

### Best Practices
1. **Capture everything:** Lower the bar for entry
2. **Process regularly:** Don't let inbox overflow
3. **Link liberally:** Connections create value
4. **Review periodically:** Weekly and monthly reviews
5. **Refactor boldly:** Improve structure as needed

### Working with AI
1. **Be specific:** Clear requests get better results
2. **Provide context:** Share relevant background
3. **Trust the agents:** They follow established patterns
4. **Review outputs:** Verify AI-generated content
5. **Iterate:** Refine instructions based on results

### Common Commands for AI

#### Note Creation
- "Create a note about [topic]"
- "Add this idea to my inbox"
- "Start a new project for [goal]"
- "Process this article into a literature note"

#### Organization
- "Organize my inbox"
- "Create a MOC for [topic]"
- "Archive completed projects"
- "Find related notes about [subject]"

#### Daily Operations
- "Create today's daily note"
- "Add this to my daily note"
- "Summarize this week"
- "Review my current projects"

### System Maintenance
1. **Weekly:** Process inbox, review projects
2. **Monthly:** Archive completed items, update MOCs
3. **Quarterly:** Review tag taxonomy, refactor structure
4. **Yearly:** Major reorganization if needed

## Integration Points

### With Obsidian
- Use Obsidian-compatible markdown
- Support for plugins via frontmatter
- Graph view optimization through links
- Tag pane compatibility
- Template compatibility

### With Other Tools
- Export to standard markdown
- API-friendly structure
- Git-compatible for version control
- Search-optimized naming
- Cross-platform compatibility

## Troubleshooting

### Common Issues
1. **Broken links:** Run link checker, update paths
2. **Duplicate notes:** Merge and redirect
3. **Orphaned notes:** Find and connect or archive
4. **Tag proliferation:** Consolidate and document
5. **Large inbox:** Dedicated processing session

### Getting Help
- Check `.claude/CLAUDE.md` for AI configuration
- Review agent files in `.claude/agents/`
- Consult templates in `05-Templates/`
- Reference this guide for standards
- Ask AI to explain its process