# Wiki Sync Architecture

## Overview
Multi-platform synchronized wiki system using git as the source of truth, with automatic commits and conflict resolution.

## Critical Configuration Details

### Authentication Setup
- **Push/Pull**: Uses SSH (`git@github.com:matttelliott/_wiki.git`)
- **SSH Agent**: 1Password manages SSH keys
- **Commit Signing**: DISABLED for auto-commits to prevent authentication prompts
- **Manual Commits**: Still signed when user commits directly

### Repository Locations

1. **Primary (macOS)**: `~/_wiki`
   - Commits as: "macos"
   - Service: `com.user.wiki-sync`
   - Runs every 5 minutes

2. **iCloud (for iOS)**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki`
   - Separate git repository (NOT a symlink - iCloud doesn't support symlinks)
   - Commits as: "icloud"
   - Service: `com.user.wiki-sync-icloud`
   - Allows iPhone Obsidian edits

3. **Linux Desktop**: `~/_wiki`
   - Commits as: "linux"
   - Uses systemd timers
   - Setup with same scripts

4. **Google Drive**: Mirrors `~/_wiki` content only
   - Excludes `.git/` via `.gignore` file
   - For iOS AI agent access
   - Managed by Google Drive app

## File Exclusions

### `.gitignore` - What git doesn't track:
```
# Sync log files only (scripts ARE tracked!)
.sync/*.log
.sync/.sync.lock
.sync/.conflict
.sync/notifications.log
.sync/sync-stdout.log
.sync/sync-stderr.log
.sync/sync-all.log

# Google Drive files
*.driveupload
*.drivedownload
.tmp.drivedownload/
Icon

# System files
.DS_Store
.obsidian/workspace*
.obsidian/cache
```

**IMPORTANT**: The `.sync/` folder scripts ARE tracked in git. Only log files are excluded to prevent merge conflicts.

### `.gignore` - What Google Drive doesn't sync:
```
.git/        # CRITICAL: Never sync git data
.sync/       # Sync system files
.obsidian/   # Local config
.claude/     # AI config
.*           # All hidden files
```

## Auto-Sync Script Details

### Current Scripts (Simplified)

#### Core Script: `wiki-sync.sh`
- **Why it exists**: We need separate git repositories for local and iCloud (iCloud doesn't support symlinks), but they share identical sync logic
- **Why single repo**: Accepts `WIKI_DIR` parameter so one script can handle any repository location
- **Why iCloud detection**: iCloud requires files to be read before it downloads pending changes from iPhone
- **Why commit-first**: Prevents iPhone edits from being lost when git stashes uncommitted changes during pull

#### Wrapper Script: `wiki-sync-all.sh`  
- **Why it exists**: Both repositories must sync to GitHub independently, but launchd can only run one command
- **Why wrapper pattern**: Simpler than configuring multiple launchd services or complex shell commands
- **Why both repos**: Local repo for fast access, iCloud repo for iPhone Obsidian compatibility

#### Helper Scripts
- **`setup-sync.sh`** - Initial setup for sync services
- **`sync-status.sh`** - Check sync status and recent activity

### Key Features
- Platform detection via `WIKI_DIR` path and `OSTYPE`
- Commits WITHOUT signing: `git -c commit.gpgsign=false commit`
- Desktop notifications for manual conflicts
- Log files excluded from git to prevent conflicts
- **iCloud file reading**: Automatically reads files when syncing iCloud repos

### Sync Flow (Unified Script)
1. Check for lock file (prevent concurrent runs)
2. Initialize git if needed
3. **If iCloud repo**: Read all markdown files to trigger downloads
4. **COMMIT local changes first** (preserves iPhone edits!)
5. Fetch and check remote status
6. Pull/merge/rebase as needed
7. Push to remote
8. Handle conflicts if they arise

**CRITICAL**: Always commits BEFORE pulling to prevent iPhone changes from being lost.

**iCloud Note**: The script automatically detects iCloud repos and reads files to trigger downloads.

## Services Configuration

### macOS (launchd)
Two separate services run independently:
- `com.user.wiki-sync` - Local repository
- `com.user.wiki-sync-icloud` - iCloud repository

Both run every 5 minutes via `StartInterval: 300`

### Linux (systemd)
- `wiki-sync.timer` - Runs every 5 minutes
- `wiki-sync.service` - Executes sync script
- `wiki-watch.service` - Optional file watcher (inotify)

## Conflict Resolution

### Automatic Resolution
System files (.sync/, .obsidian/) are auto-resolved by keeping local version

### Manual Conflicts
1. Creates `.sync/.conflict` flag file
2. Sends desktop notification
3. Logs conflicted files
4. Waits for user resolution

## Monitoring

### Check Status
```bash
~/_wiki/.sync/sync-status.sh
```
Shows:
- Git status for current repo
- Service status (both local and iCloud on macOS)
- Recent sync activity
- Active conflicts

### Log Files
- Sync log: `~/_wiki/.sync/sync.log`
- Notifications: `~/_wiki/.sync/notifications.log`
- Service output: `~/_wiki/.sync/sync-stdout.log`
- Service errors: `~/_wiki/.sync/sync-stderr.log`

### Common Log Patterns
- `Committed changes: Auto-sync from [platform]` - Normal operation
- `Pushed changes to remote` - Successfully synced
- `Failed to fetch from remote` - Network issue (will retry)
- `Push failed, attempting to sync` - Pulling remote changes

## Setup Instructions

### macOS
```bash
cd ~/_wiki
~/_wiki/.sync/setup-sync.sh
```

### Linux
```bash
git clone git@github.com:matttelliott/_wiki.git ~/_wiki
cd ~/_wiki
~/_wiki/.sync/setup-sync.sh
```

### iOS Setup
1. Install Obsidian on iOS
2. Open vault from iCloud Drive: `Wiki` folder
3. Changes sync automatically via iCloud service

## Troubleshooting

### Push Failures
If seeing repeated "Push failed" in logs:
```bash
cd ~/_wiki
git pull origin main
git push origin main
```

### Authentication Prompts
Should NOT happen. If they do:
1. Check commit signing is disabled in sync script
2. Verify SSH key is in 1Password
3. Check SSH config includes 1Password agent

### iCloud Not Syncing
1. Verify it's a separate repo: `cd ~/Library/.../Wiki && git status`
2. Check service: `launchctl list | grep wiki-sync-icloud`
3. Restart service: `launchctl unload/load ~/Library/LaunchAgents/com.user.wiki-sync-icloud.plist`

### Conflicts
1. Check `.sync/.conflict` for details
2. Resolve in affected files
3. Stage and commit manually
4. Remove conflict flag: `rm .sync/.conflict`

## Important Notes

1. **Never symlink iCloud** - It doesn't work, use separate repo
2. **Keep .git out of Google Drive** - Use .gignore file
3. **Disable signing for auto-commits** - Prevents auth prompts
4. **Each platform commits with identifier** - Track change source
5. **Services run independently** - Local and iCloud don't interfere

## Architecture Diagram

```
GitHub Repository
      ↑↓ SSH
┌─────────────────┐
│  macOS Local    │ ←── Google Drive App ──→ Google Drive
│   (~/_wiki)     │                              ↓
│ [commits:macos] │                         iOS AI Agents
└─────────────────┘
      
┌─────────────────┐
│  macOS iCloud   │ ←── iCloud Sync ──→ iPhone Obsidian
│ (~/Library/...) │
│[commits:icloud] │
└─────────────────┘

┌─────────────────┐
│  Linux Desktop  │
│   (~/_wiki)     │
│ [commits:linux] │
└─────────────────┘
```

All three repositories pull/push to the same GitHub repo independently, creating a distributed sync system with git as the source of truth.