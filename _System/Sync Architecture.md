# Wiki Sync Architecture

## Overview
Multi-location sync system with git as primary source of truth, supporting iOS editing and AI agent access.

## Sync Locations
1. **Primary:** `~/_wiki` on MacBook (working copy)
2. **Version Control:** Self-hosted git server (when configured)
3. **iOS Access:** iCloud Drive via Obsidian
4. **AI Agent Access:** Google Drive (via Google Drive app)

## Architecture

```
┌─────────────┐     git push/pull      ┌──────────────┐
│  MacBook    │ ◄──────────────────► │  Git Server  │
│  ~/_wiki    │      (auto-commit)     │  (Source of  │
│             │                        │   Truth)     │
└──────┬──────┘                        └──────────────┘
       │
       ├── symlink ──► iCloud Drive ◄── iOS Obsidian
       │
       └── Google Drive app ──► Google Drive ◄── iOS AI Agents
```

## Auto-Commit System

### Components
1. **Git auto-commit** - Every 5 minutes via launchd
2. **File watcher** - Immediate commits on file changes (if fswatch installed)
3. **Sync with remote** - Automatic push/pull when remote configured

### Setup
Run the setup script:
```bash
~/_wiki/.sync/setup-sync.sh
```

This installs:
- `com.user.wiki-sync` - Periodic git commits (5 min)
- `com.user.wiki-watch` - File change watcher (optional)

### Git Configuration
The system automatically:
- Commits all changes with timestamp
- Pulls before pushing (with rebase)
- Handles merge conflicts gracefully
- Logs all operations to `.sync/sync.log`

## iCloud Integration

### For iOS Obsidian
- Wiki is symlinked to iCloud Obsidian folder
- Changes sync bidirectionally
- iOS edits appear in working copy
- Git commits capture iOS changes

### Setup
1. Install Obsidian on iOS
2. Run setup script (creates symlink)
3. Open vault from iCloud in iOS Obsidian

## Google Drive Integration

### For iOS AI Agents
- Google Drive app handles sync
- Provides read/write access to iOS shortcuts and AI agents
- No additional configuration needed

### Path
- Local: `~/_wiki`
- Google Drive: `~/Google Drive/My Drive/_wiki` (or configured path)

## Conflict Resolution

### Priority Order
1. **Git repository** - Ultimate source of truth
2. **Local ~/_wiki** - Working copy
3. **iCloud/Google Drive** - Distribution copies

### Conflict Handling
- Git handles versioning and merging
- Auto-commit captures all changes
- Manual resolution for git conflicts
- Other sync services follow git state

## Monitoring

### Check Status
```bash
~/_wiki/.sync/sync-status.sh
```

Shows:
- Git status and last commit
- Service status (running/stopped)
- Recent sync activity
- Storage location status

### Logs
- Sync log: `~/_wiki/.sync/sync.log`
- Service output: `~/_wiki/.sync/sync-stdout.log`
- Service errors: `~/_wiki/.sync/sync-stderr.log`

### Manual Sync
```bash
~/_wiki/.sync/wiki-auto-sync.sh
```

## Workflow

### Daily Usage
1. **Edit anywhere** - MacBook, iOS Obsidian, or via AI agents
2. **Auto-commit** captures changes within 5 minutes (or immediately with fswatch)
3. **Sync propagates** to all locations
4. **Git maintains** full history

### Adding Git Remote
When git server is ready:
```bash
cd ~/_wiki
git remote add origin [git-url]
git push -u origin main
```

Auto-sync will then push/pull automatically.

## Troubleshooting

### Service Not Running
```bash
launchctl load ~/Library/LaunchAgents/com.user.wiki-sync.plist
launchctl load ~/Library/LaunchAgents/com.user.wiki-watch.plist
```

### Force Sync
```bash
cd ~/_wiki
git add -A
git commit -m "Manual sync"
git pull --rebase origin main
git push origin main
```

### Reset Services
```bash
launchctl unload ~/Library/LaunchAgents/com.user.wiki-*.plist
launchctl load ~/Library/LaunchAgents/com.user.wiki-*.plist
```

### Check for Conflicts
```bash
cd ~/_wiki
git status
git diff
```

## File Exclusions

Auto-ignored by git:
- `.DS_Store`
- `.sync/`
- `.obsidian/workspace*`
- `.obsidian/cache`
- `.trash/`
- `*.tmp`

These files don't sync to preserve local state.