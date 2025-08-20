#!/bin/bash

# bidirectional-sync.sh - True two-way sync between local and iCloud wikis
#
# WHY THIS EXISTS:
# - Each location needs TWO sync cycles for bidirectional sync
# - First cycle: Push local changes to GitHub
# - Second cycle: Pull changes from the other location
# - Without this, changes from one location don't appear in the other
#
# HOW IT WORKS:
# 1. Both repos commit and push their local changes
# 2. Wait briefly for GitHub to process
# 3. Both repos pull to get each other's changes
# 4. Result: Both locations have all changes

# Paths
LOCAL_WIKI="$HOME/_wiki"
ICLOUD_WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki"
AUTO_SYNC="$LOCAL_WIKI/.sync/auto-sync-with-conflicts.sh"
LOG_FILE="$LOCAL_WIKI/.sync/bidirectional.log"

# Logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

log_message "Starting bidirectional sync"

# PHASE 1: Both locations push their changes
log_message "Phase 1: Pushing local changes from both locations..."

# Local wiki - commit and push
if [ -d "$LOCAL_WIKI" ]; then
    log_message "  Syncing local wiki..."
    "$AUTO_SYNC" -d "$LOCAL_WIKI" -q &
    LOCAL_PID=$!
else
    log_message "  Local wiki not found"
fi

# iCloud wiki - commit and push (with file reading)
if [ -d "$ICLOUD_WIKI" ]; then
    log_message "  Syncing iCloud wiki..."
    "$AUTO_SYNC" -d "$ICLOUD_WIKI" -i -q &
    ICLOUD_PID=$!
else
    log_message "  iCloud wiki not found"
fi

# Wait for both to complete
if [ -n "$LOCAL_PID" ]; then
    wait $LOCAL_PID
    log_message "  Local sync complete"
fi
if [ -n "$ICLOUD_PID" ]; then
    wait $ICLOUD_PID
    log_message "  iCloud sync complete"
fi

# Brief pause to ensure GitHub has processed pushes
sleep 2

# PHASE 2: Both locations pull to get each other's changes
log_message "Phase 2: Pulling changes to both locations..."

# Run sync again to pull any new changes
if [ -d "$LOCAL_WIKI" ]; then
    log_message "  Pulling to local wiki..."
    "$AUTO_SYNC" -d "$LOCAL_WIKI" -q &
    LOCAL_PID=$!
fi

if [ -d "$ICLOUD_WIKI" ]; then
    log_message "  Pulling to iCloud wiki..."
    "$AUTO_SYNC" -d "$ICLOUD_WIKI" -i -q &
    ICLOUD_PID=$!
fi

# Wait for both to complete
if [ -n "$LOCAL_PID" ]; then
    wait $LOCAL_PID
    log_message "  Local pull complete"
fi
if [ -n "$ICLOUD_PID" ]; then
    wait $ICLOUD_PID
    log_message "  iCloud pull complete"
fi

log_message "Bidirectional sync complete"

# Cleanup old log entries (keep last 500 lines)
if [ $(wc -l < "$LOG_FILE" 2>/dev/null || echo 0) -gt 500 ]; then
    tail -n 500 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi