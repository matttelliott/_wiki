# Claude Configuration for Personal Wiki

## Overview
This personal knowledge wiki uses the PARA method (Projects, Areas, Resources, Archives) combined with GTD (Getting Things Done) principles. The wiki is designed to be AI-agent friendly, with specific instructions and subagents for various knowledge management tasks.

## IMPORTANT: Proactive Agent Usage
**Claude should ALWAYS proactively use the appropriate subagent when:**
- Creating or organizing notes - use `wiki-note-creator` agent
- Processing daily entries - use `daily-note-assistant` agent
- Managing projects - use `project-manager` agent
- Capturing ideas - use `idea-capturer` agent
- Processing literature/research - use `literature-processor` agent
- Organizing existing content - use `knowledge-organizer` agent
- Generating comprehensive content - use `prompt-engineer-expert` agent

**DO NOT wait for explicit requests to use agents. Automatically invoke the relevant agent based on the task context.**

## Directory Structure
```
_wiki/
├── 00-Inbox/           # Capture point for new ideas and notes
├── 01-Projects/        # Active and completed projects
├── 02-Areas/          # Ongoing responsibilities
├── 03-Resources/      # Reference materials
├── 04-Daily/          # Daily notes and journal entries
├── 05-Templates/      # Note templates
├── 06-Attachments/    # Media and file attachments
└── _System/           # System documentation and configurations
```

## Agent Instructions

### Automatic Agent Selection Rules
1. **Note Creation**: ANY request to create notes → use `wiki-note-creator` agent
2. **Daily Activities**: Working with daily notes or journals → use `daily-note-assistant` agent
3. **Project Work**: Project documentation or tracking → use `project-manager` agent
4. **Idea Processing**: Quick thoughts or brainstorming → use `idea-capturer` agent
5. **Research**: Literature notes or research synthesis → use `literature-processor` agent
6. **Organization**: Restructuring or categorizing → use `knowledge-organizer` agent
7. **Complex Prompts**: Vague or multi-part requests → use `prompt-engineer-expert` agent first

### Available Subagents
Located in `.claude/agents/` directory:
- `wiki-note-creator.md` - Creates structured notes following templates
- `knowledge-organizer.md` - Helps organize and categorize information
- `daily-note-assistant.md` - Manages daily notes and journal entries
- `project-manager.md` - Assists with project documentation and tracking
- `literature-processor.md` - Processes and creates literature notes
- `idea-capturer.md` - Quick capture and processing of ideas

### Working with Notes

#### Creating New Notes
1. **ALWAYS use `wiki-note-creator` agent automatically**
2. Agent will determine appropriate category (Inbox, Projects, Areas, Resources)
3. Agent will use relevant template from `05-Templates/`
4. Include frontmatter with creation date and tags
5. Create bidirectional links to related notes
6. Place attachments in `06-Attachments/`

#### Organizing Information
- **Automatically invoke `knowledge-organizer` agent for any organization tasks**
- New captures go to `00-Inbox/` first
- Process inbox items regularly to appropriate locations
- Active projects in `01-Projects/_Active/`
- Completed projects move to `01-Projects/_Completed/`
- Reference materials in `03-Resources/`

#### Daily Notes
- **Always use `daily-note-assistant` agent for daily note operations**
- Format: `YYYY-MM-DD.md` in `04-Daily/`
- Include sections for: Tasks, Notes, Reflections
- Link to relevant project and area notes

### Search and Navigation
- Use the INDEX.md as the main entry point
- Search by tags, links, or content
- Maintain consistent tag taxonomy
- Update INDEX.md when adding major new sections

### Best Practices
1. **Proactively suggest using agents for better results**
2. One idea per note (atomic notes)
3. Write notes in your own words
4. Make notes self-contained but well-linked
5. Use descriptive titles that complete "This note is about..."
6. Regular reviews and refactoring of notes
7. Progressive summarization for long-form content

## Wiki-Specific Conventions
- Use `[[wikilinks]]` for internal connections
- Tags use `#` format (e.g., `#project/active`)
- Frontmatter includes: date, tags, type, status
- Follow Obsidian markdown extensions
- Maintain consistent heading hierarchy

## Special Considerations
- Respect existing note structure and formatting
- Preserve all existing links when editing
- Maintain chronological order in daily notes
- Keep templates generic and reusable
- Document any new workflows in `_System/`
- **Always consider which agent would best handle the task**

## Project Sync Protocol
When receiving status reports from other Claude instances:
1. Parse the status report format (see `_System/Claude Sync Protocol.md`)
2. Update or create project note in `01-Projects/_Active/`
3. Log sync in project's sync log section
4. Flag any conflicts or discrepancies for user review
5. Focus on "what actually works" as ground truth

To generate status for another Claude:
1. Read the relevant project note
2. Format using standard status report structure
3. Include confidence levels for each item
4. Note any uncertainties or conflicts

## Critical Wiki Sync Information

### Repository Setup
This wiki uses a complex multi-repository sync system. There are THREE separate git repositories:
1. **Local**: `~/_wiki` (primary working copy)
2. **iCloud**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki` (for iOS)
3. **GitHub**: `git@github.com:matttelliott/_wiki.git` (central hub)

**IMPORTANT**: iCloud location is a SEPARATE CLONE, not a symlink!

### Auto-Sync Configuration
- Commits run automatically every 5 minutes
- Commit signing is DISABLED for auto-commits: `git -c commit.gpgsign=false commit`
- SSH authentication via 1Password agent
- Each platform identifies itself in commits (macos/icloud/linux)

### File Exclusions
- `.gitignore` keeps Google Drive files out of git
- `.gignore` keeps `.git/` folder out of Google Drive
- This separation is CRITICAL for proper operation

### Troubleshooting Sync Issues
If you see sync failures:
1. Check `_System/Sync Architecture.md` for complete details
2. Run `~/_wiki/.sync/sync-status.sh` to diagnose
3. Check logs at `~/_wiki/.sync/sync.log`
4. Network issues auto-retry every 5 minutes

### For Manual Operations
- Changes commit automatically - wait 5 minutes or run: `~/_wiki/.sync/wiki-auto-sync.sh`
- To force sync: `git pull origin main && git push origin main`
- Status updates between Claudes: Use `_System/Claude Sync Protocol.md`