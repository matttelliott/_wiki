#!/bin/bash

# Wiki Sync All - Syncs both local and iCloud wiki repositories
# Uses the unified wiki-sync.sh script for both locations

# Configuration - modify these if your paths are different
LOCAL_WIKI="${LOCAL_WIKI:-$HOME/_wiki}"
ICLOUD_WIKI="${ICLOUD_WIKI:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki}"

# Log file for this wrapper
SYNC_ALL_LOG="$LOCAL_WIKI/.sync/sync-all.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$SYNC_ALL_LOG"
}

log_message "Starting sync for all wiki locations"

# Sync local wiki
if [ -d "$LOCAL_WIKI" ]; then
    log_message "Syncing local wiki at $LOCAL_WIKI"
    WIKI_DIR="$LOCAL_WIKI" /bin/bash "$LOCAL_WIKI/.sync/wiki-sync.sh"
    log_message "Local wiki sync complete"
else
    log_message "WARNING: Local wiki not found at $LOCAL_WIKI"
fi

# Sync iCloud wiki (the unified script handles iCloud-specific logic)
if [ -d "$ICLOUD_WIKI" ]; then
    log_message "Syncing iCloud wiki at $ICLOUD_WIKI"
    WIKI_DIR="$ICLOUD_WIKI" /bin/bash "$LOCAL_WIKI/.sync/wiki-sync.sh"
    log_message "iCloud wiki sync complete"
else
    log_message "WARNING: iCloud wiki not found at $ICLOUD_WIKI"
fi

log_message "All wiki syncs complete"

# Cleanup old log entries (keep last 500 lines)
if [ -f "$SYNC_ALL_LOG" ] && [ $(wc -l < "$SYNC_ALL_LOG") -gt 500 ]; then
    tail -n 500 "$SYNC_ALL_LOG" > "$SYNC_ALL_LOG.tmp"
    mv "$SYNC_ALL_LOG.tmp" "$SYNC_ALL_LOG"
fi