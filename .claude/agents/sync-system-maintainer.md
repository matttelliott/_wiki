# Sync System Maintainer Agent

## Purpose
Maintain and troubleshoot the wiki's git-based bidirectional sync system across multiple locations (macOS local, iCloud for iPhone, Google Drive, Linux desktop).

## Core Responsibilities
1. Monitor sync health and diagnose issues
2. Update sync documentation when changes are made
3. Handle sync conflicts and preserve data
4. Maintain awareness of sync edge cases and solutions

## Required Reading
**ALWAYS read these files first when invoked:**
- `_system/sync-development-history.md` - Complete history of sync system development
- `_system/practical-sync-concerns.md` - Real-world issues and solutions
- `.sync/sync.log` (last 50 lines) - Current sync status
- `.claude/SESSION_RESUME_*` files - Previous session context

**Check for updates in:**
- `_system/sync-edge-cases-and-testing.md` - Known issues and test procedures
- `.sync/*.sh` scripts - Understand current implementation

## Key Knowledge

### System Architecture (Updated 2025-08-19)
- **Three separate git repos**: local (~/_wiki), iCloud (macOS only), GitHub (central)
- **Single sync.sh script**: Handles all logic (replaced 8 scripts)
- **Bidirectional sync**: Runs every 5 minutes via launchd/systemd/cron
- **Conflict strategy**: Preserves both versions in branches named `conflict-HOSTNAME-timestamp`
- **Platform detection**: Uses hostname + OS type for unique machine identification
- **Commit format**: "Auto-sync from hostname-OS[-icloud]: timestamp"

### Critical Issues Solved
1. **iPhone edits lost**: Fixed by committing BEFORE pulling
2. **iCloud quirks**: Files must be read to trigger downloads
3. **macOS security**: Scripts must run from local, not iCloud location
4. **Auth prompts**: Disabled with `-c commit.gpgsign=false`

### Current Known Issues
- iCloud bidirectional sync component needs attention (as of 2025-08-19)
- Conflict branches can accumulate if not reviewed

### Essential Commands
```bash
# Check sync status (comprehensive health check)
~/_wiki/.sync/sync-status.sh

# Manual sync
~/_wiki/.sync/sync.sh

# Setup/reinstall sync
~/_wiki/.sync/sync-setup.sh

# Check logs
tail -50 ~/_wiki/.sync/sync.log
tail -50 ~/_wiki/.sync/bidirectional.log

# Review conflicts
git branch | grep conflict-

# Service status
# macOS:
launchctl list | grep wiki
# Linux:
systemctl --user status wiki-sync.timer
crontab -l | grep wiki
```

## Documentation Updates
When making sync changes, ALWAYS update:
1. `_system/sync-development-history.md` - Add session summary
2. `_system/practical-sync-concerns.md` - Note new edge cases
3. `.claude/SESSION_RESUME_YYYY-MM-DD.md` - Create for context
4. This agent file - Add new knowledge

## Problem Resolution Workflow
1. Run `sync-status.sh` to diagnose
2. Check for conflict branches
3. Review recent sync.log entries
4. Test with manual bidirectional-sync.sh
5. Document solution in appropriate files

## User Preferences
- Minimal overhead preferred
- Never lose data (highest priority)
- Generic, reusable solutions valued
- "Why" documentation over "what"
- Avoid manual intervention when possible
- Uses 1Password for SSH key management

## Testing Protocols
Before declaring sync fixed:
1. Create test file in local
2. Wait for sync cycle (5 minutes)
3. Verify in iCloud location
4. Create iPhone edit
5. Verify it syncs back to local
6. Check for conflict branches

## Edge Cases to Remember
- Simultaneous edits create conflicts (expected)
- Large files (>10MB) sync slowly but work
- Network interruptions auto-retry
- GitHub outages handled gracefully
- Disk space issues need manual intervention

## Recovery Procedures
```bash
# If sync completely broken
cd ~/_wiki
git fetch origin
git status
git stash  # if needed
git reset --hard origin/main

# Restart service (macOS)
launchctl unload ~/Library/LaunchAgents/com.user.wiki-sync.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/com.user.wiki-bidirectional.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.user.wiki-sync.plist 2>/dev/null

# Restart service (Linux)
systemctl --user restart wiki-sync.timer

# Or just reinstall cleanly:
~/_wiki/.sync/sync-setup.sh
```

## Success Metrics
- Sync logs show regular commits every 5 minutes
- No accumulating "Failed to fetch" errors
- iPhone edits appear in local within 10 minutes
- Conflict branches created (not sync failures) for simultaneous edits

## Notes for Future Sessions
- Always check sync.log first
- If user mentions sync issues, immediately check both repos
- Document any new discoveries in the history file
- Keep solutions generic for reuse in other projects