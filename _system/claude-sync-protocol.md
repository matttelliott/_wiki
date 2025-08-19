# Claude-to-Claude Sync Protocol

## Overview
A simple bidirectional sync system between Project Claude and Wiki Claude that tracks task status without relying on external tools.

## Status Report Format

Both Claudes use this format:

```markdown
=== CLAUDE STATUS REPORT ===
Project: [Project Name]
Date: YYYY-MM-DD HH:MM
Session ID: [unique identifier]

## Completed (Done)
- [x] Task description | confidence: high/medium/low
- [x] Task description | note: [any relevant detail]

## Active (Working On)
- [ ] Task description | progress: 75%
- [ ] Task description | blocked: [reason]

## Queued (Not Started)
- [ ] Task description | priority: high/medium/low

## Reality Check
Last verified working: [what actually runs/works]
Known issues: [what's broken]
=== END STATUS REPORT ===
```

## Sync Process

### 1. Getting Status from Project Claude
Ask: "Generate a status report - what's actually done, what's in progress, what's planned?"

### 2. Importing to Wiki Claude
Say: "Sync project status: [paste report]"

### 3. Exporting from Wiki Claude
Ask: "Export project status for [Project Name]"

### 4. Updating Project Claude
Say: "Update from wiki: [paste wiki status]"

## Reconciliation Rules

When task lists differ, ask these questions:

1. **What actually works right now?** (Ground truth)
2. **What did we claim was done?** (Both lists)
3. **What's the simplest explanation for the difference?**

### Common Scenarios

```markdown
Wiki says: Task A [done]
Project says: Task A [in progress]
→ Ask: "Is Task A actually working?" 
→ Update both to match reality

Wiki says: Task B [not listed]
Project says: Task B [done]
→ Add to wiki with note "discovered in sync"

Both say: Task C [done]
Reality: Task C doesn't work
→ Move to "Active" with note "needs fix"
```

## Simple Tracking

Add to project notes:

```markdown
## Sync Log
- 2024-01-15: Synced with Project Claude
  - Added: Task X, Y
  - Completed: Task Z
  - Conflicts: Task A (marked as active, was listed as done)
```

## Quick Confidence Check

When uncertain about status:

**High Confidence:**
- "I just tested this and it works"
- "I completed this and verified it"

**Medium Confidence:**
- "I believe this was done"
- "This should be working"

**Low Confidence:**
- "This might be done"
- "I think we worked on this"

## Minimal Overhead Tips

1. **Sync only when switching Claudes** - Not every session
2. **Focus on changes** - Don't re-list everything
3. **Trust but verify** - Quick reality checks over detailed tracking
4. **When in doubt, test it** - Actual functionality beats documentation