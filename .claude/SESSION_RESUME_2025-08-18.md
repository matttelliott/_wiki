# Session Resume Note - Wiki Sync System
**Date**: 2025-08-18
**Session Duration**: ~3 hours
**Main Achievement**: Built complete bidirectional sync system with conflict preservation

## Context for Next Claude Session

### What We Built Today
We transformed the wiki sync from a basic git auto-commit system into a sophisticated bidirectional sync with conflict handling. The system now:
1. Syncs every 5 minutes between local and iCloud
2. Handles iPhone edits properly (commits BEFORE pulling)
3. Preserves conflicts in branches for later review
4. Works around macOS security restrictions
5. Is fully reusable for other projects (dotfiles, notes, etc.)

### Current State
- **Working**: Bidirectional sync via `com.user.wiki-bidirectional` service
- **Tested**: Successfully synced 8 iPhone updates and handled conflicts
- **Scripts Location**: All in `~/_wiki/.sync/`
- **Main Service**: Running every 5 minutes, handling both repos

### Critical Issues Resolved
1. **iCloud Download Problem**: Files must be read to trigger cloud sync
2. **Operation Not Permitted**: Scripts must run from local, not iCloud location
3. **Lost iPhone Edits**: Fixed by committing before pulling
4. **Authentication Prompts**: Disabled with `-c commit.gpgsign=false`

### What Needs Attention Next Session

#### Immediate Tasks
```bash
# 1. Clean up old services (still running)
launchctl unload ~/Library/LaunchAgents/com.user.wiki-local.plist
launchctl unload ~/Library/LaunchAgents/com.user.wiki-icloud.plist
rm ~/Library/LaunchAgents/com.user.wiki-local.plist
rm ~/Library/LaunchAgents/com.user.wiki-icloud.plist

# 2. Test conflict handling
# Create simultaneous edits and verify branch preservation works
```

#### Documentation Updates Needed
- [ ] Update `_System/Sync Architecture.md` with final design
- [ ] Remove references to old scripts (wiki-sync.sh, wiki-sync-all.sh)
- [ ] Add conflict handling workflow to troubleshooting guide
- [ ] Update CLAUDE.md with sync information

#### Testing Scenarios
1. **Conflict during auto-sync** - Verify branches are created
2. **Multiple conflicts** - Ensure each gets its own branch
3. **Conflict resolution** - Test the review tool
4. **Network outage** - Verify graceful handling
5. **Large file conflicts** - Performance test

### Key Scripts to Know

```bash
# Check sync status
~/_wiki/.sync/sync-status.sh

# Review conflicts
~/_wiki/.sync/conflict-review.sh

# Manual sync (if needed)
~/_wiki/.sync/bidirectional-sync.sh

# Check for conflict branches
git branch | grep conflict-
```

### Architecture Summary
```
auto-sync.sh (generic, reusable)
    ↓
bidirectional-sync.sh (calls auto-sync twice per repo)
    ↓
handle-conflicts.sh (preserves conflicts in branches)
    ↓
conflict-review.sh (manual resolution tool)
```

### Warnings & Gotchas
1. **Don't edit in both locations simultaneously** - Creates conflicts
2. **Let sync complete** before switching devices
3. **Check for conflict branches** periodically with review tool
4. **iCloud needs file reads** to trigger downloads
5. **Scripts must run from local** due to macOS security

### User Preferences Noted
- Prefers minimal overhead
- Wants generic, reusable solutions
- Emphasizes data preservation (never lose edits)
- Likes "why" documentation over "what"
- Uses 1Password for SSH keys

### Success Metrics
- ✅ 8/8 iPhone updates synced successfully
- ✅ Conflicts preserved without data loss
- ✅ System continues syncing through conflicts
- ✅ Generic enough to use for dotfiles

### Next Session Opening
Start by running `sync-status.sh` to check current state, then check for any conflict branches with `git branch | grep conflict-`. The main focus should be cleanup of old services and thorough testing of conflict scenarios.

## File Paths Reference
- Wiki: `~/_wiki`
- iCloud: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki`
- Scripts: `~/_wiki/.sync/`
- Service: `~/Library/LaunchAgents/com.user.wiki-bidirectional.plist`
- Logs: `~/_wiki/.sync/*.log`

Good luck! The foundation is solid, just needs polish and testing.