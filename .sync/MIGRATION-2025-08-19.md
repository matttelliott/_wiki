# Sync System Simplification - 2025-08-19

## What Changed
Consolidated from 8 scripts to 3 clean scripts for better maintainability.

## New Scripts (Keep These)
1. **sync.sh** - All sync logic in one place
   - Handles bidirectional sync
   - Conflict preservation 
   - Multi-platform support
   - Unique machine names in commits

2. **sync-setup.sh** - Easy installation
   - macOS: launchd
   - Linux: systemd or cron (user choice)
   - Auto-detects platform

3. **sync-status.sh** - Health monitoring
   - Shows scheduler status
   - Repository sync state
   - Conflict branches
   - Recent activity

## Old Scripts (Archived to .sync/archived/)
- auto-sync.sh
- auto-sync-with-conflicts.sh  
- bidirectional-sync.sh
- handle-conflicts.sh
- conflict-review.sh
- install-auto-sync.sh
- setup-sync.sh

## Current Service
The existing `com.user.wiki-bidirectional` launchd service is still running and working.
When ready to switch to the new simplified version, run:
```bash
~/_wiki/.sync/sync-setup.sh
```

## Key Improvements
- Each machine now identified uniquely (e.g., "Matts-MacBook-Air-macos")
- Single script handles all complexity
- Easier to understand and maintain
- Works identically across platforms