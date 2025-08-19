# Wiki Sync System

## Overview
Building a robust, bidirectional sync system for the personal wiki that works across macOS local, iCloud (for iPhone), and other locations.

## Status: In Progress

### Completed Today (2025-08-18)

#### ✅ Phase 1: Basic Sync Setup
- Set up git-based sync with automatic commits every 5 minutes
- Configured separate repositories for local (~/_wiki) and iCloud
- Disabled commit signing to prevent authentication prompts
- Successfully tested with 8 iPhone updates

#### ✅ Phase 2: Script Simplification
- Consolidated from 6 scripts down to 4 core scripts
- Created unified `wiki-sync.sh` that handles both local and iCloud
- Added iCloud file reading to trigger cloud downloads
- Fixed "Operation not permitted" errors by running scripts from local location

#### ✅ Phase 3: Generic Reusable System
- Created `auto-sync.sh` - fully generic sync script for ANY git repository
- Built `install-auto-sync.sh` - universal installer for macOS/Linux/Windows
- Works for dotfiles, notes, or any frequently-changing repos
- Published with documentation for reuse

#### ✅ Phase 4: True Bidirectional Sync
- Created `bidirectional-sync.sh` that runs both repos twice
- Phase 1: Both push their changes
- Phase 2: Both pull to get each other's changes
- Single service replaces two separate ones

#### ✅ Phase 5: Conflict Handling
- Implemented Conflict Branch Strategy
- Conflicts preserved in timestamped branches
- Main branch resets to continue syncing
- `conflict-review.sh` tool for later resolution
- Both versions always preserved in git history

### Lessons Learned

1. **iCloud Quirks**
   - Doesn't support symlinks
   - Requires files to be read to trigger downloads
   - macOS blocks script execution in iCloud folders

2. **Commit Ordering**
   - MUST commit before pulling to preserve iPhone edits
   - Original pull-first approach lost changes in git stash

3. **Authentication**
   - 1Password SSH manages keys
   - Commit signing must be disabled for auto-commits
   - Use `-c commit.gpgsign=false` flag

4. **Conflicts**
   - Will occur with simultaneous edits
   - Branch strategy preserves both versions
   - Sync can continue without manual intervention

### Current Architecture

```
GitHub (Source of Truth)
         ↑↓
┌──────────────────┐
│ Bidirectional    │
│ Sync Service     │
│ (every 5 min)    │
└──────────────────┘
      ↓        ↓
Local Wiki   iCloud Wiki
(~/_wiki)    (~/Library/...)
     ↓            ↓
Google Drive  iPhone Obsidian
```

### Remaining Tasks

#### High Priority
- [ ] Test conflict handling thoroughly with real scenarios
- [ ] Clean up old launchd services (wiki-local, wiki-icloud)
- [ ] Update all documentation to reflect new system
- [ ] Ensure generic scripts stay reusable for other projects

#### Medium Priority
- [ ] Add notifications for preserved conflicts
- [ ] Create dashboard for sync status
- [ ] Build conflict resolution UI
- [ ] Add sync health monitoring

#### Low Priority
- [ ] Support for more conflict resolution strategies
- [ ] Automated conflict resolution for simple cases
- [ ] Integration with Obsidian sync indicator
- [ ] Performance optimization for large repos

### Files & Locations

#### Core Scripts
- `/Users/matt/_wiki/.sync/auto-sync.sh` - Generic reusable sync
- `/Users/matt/_wiki/.sync/bidirectional-sync.sh` - Two-way sync wrapper
- `/Users/matt/_wiki/.sync/handle-conflicts.sh` - Conflict preservation
- `/Users/matt/_wiki/.sync/conflict-review.sh` - Conflict resolution tool
- `/Users/matt/_wiki/.sync/install-auto-sync.sh` - Universal installer

#### Services
- `~/Library/LaunchAgents/com.user.wiki-bidirectional.plist` - Main service

#### Documentation
- `_System/Sync Architecture.md` - Technical details
- `_System/sync-troubleshooting.md` - Common issues
- `_System/Generic Auto-Sync Guide.md` - Reuse guide
- `_System/Conflict Handling in Bidirectional Sync.md` - Conflict behavior

### Testing Notes

Successfully synced:
- 8 iPhone updates through iCloud
- Bidirectional file creation
- Conflict preservation in branches
- Recovery from authentication issues
- Operation across macOS security boundaries

### Next Session Focus

1. **Cleanup**: Remove old services and scripts
2. **Testing**: Thorough conflict scenarios
3. **Documentation**: Update all docs to current state
4. **Polish**: Make scripts production-ready

## Links
- [GitHub Repository](https://github.com/matttelliott/_wiki)
- Related: [[Git]], [[Automation]], [[iPhone Sync]]