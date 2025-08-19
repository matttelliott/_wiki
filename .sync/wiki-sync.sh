#!/bin/bash

# wiki-sync.sh - Core Sync Script for a Single Repository
# 
# WHY THIS SCRIPT EXISTS:
# - Syncs ONE git repository at a time (specified by WIKI_DIR environment variable)
# - Reusable for any repository location (local, iCloud, or future locations)
# - Handles iCloud's quirk where files must be read to trigger cloud downloads
# - Commits BEFORE pulling to prevent iPhone edits from being lost
#
# USAGE:
#   WIKI_DIR="/path/to/repo" /bin/bash wiki-sync.sh
#
# CALLED BY:
#   wiki-sync-all.sh (wrapper that syncs multiple repos)

WIKI_DIR="${WIKI_DIR:-$HOME/_wiki}"
SYNC_LOG="$WIKI_DIR/.sync/sync.log"
LOCK_FILE="$WIKI_DIR/.sync/.sync.lock"
CONFLICT_FLAG="$WIKI_DIR/.sync/.conflict"

# Ensure log directory exists
mkdir -p "$WIKI_DIR/.sync"

# Detect platform
if [[ "$WIKI_DIR" == *"iCloud~md~obsidian"* ]]; then
    PLATFORM="icloud"
    IS_ICLOUD=true
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    IS_ICLOUD=false
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    IS_ICLOUD=false
else
    PLATFORM="unknown"
    IS_ICLOUD=false
fi

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$PLATFORM] $1" >> "$SYNC_LOG"
}

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if [[ "$PLATFORM" == "macos" ]] || [[ "$PLATFORM" == "icloud" ]]; then
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"Submarine\""
    elif [[ "$PLATFORM" == "linux" ]]; then
        if command -v notify-send &> /dev/null; then
            notify-send --urgency="$urgency" "$title" "$message"
        fi
    fi
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] NOTIFICATION: $title - $message" >> "$WIKI_DIR/.sync/notifications.log"
}

# Function to trigger iCloud file downloads (only for iCloud repos)
trigger_icloud_sync() {
    if [ "$IS_ICLOUD" = true ]; then
        log_message "Triggering iCloud file sync by reading files..."
        
        # Read all markdown files to trigger iCloud download
        # This is necessary because iCloud doesn't always download files automatically
        find "$WIKI_DIR" -type f -name "*.md" -not -path "*/\.git/*" -not -path "*/\.sync/*" -not -path "*/\.obsidian/*" 2>/dev/null | while read -r file; do
            # Simply reading the file triggers iCloud to download it if needed
            head -n 1 "$file" > /dev/null 2>&1
        done
        
        # Give iCloud a moment to complete downloads
        sleep 2
        
        log_message "iCloud file sync triggered"
    fi
}

# Check for lock file
if [ -f "$LOCK_FILE" ]; then
    # If lock file is older than 5 minutes, remove it (stale)
    if [[ $(find "$LOCK_FILE" -mmin +5 2>/dev/null) ]]; then
        log_message "Removing stale lock file"
        rm -f "$LOCK_FILE"
    else
        # Another sync is running, exit silently
        exit 0
    fi
fi

# Create lock file
touch "$LOCK_FILE"

# Cleanup function
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

cd "$WIKI_DIR" || exit 1

# Initialize git if needed
if [ ! -d .git ]; then
    log_message "Initializing git repository"
    git init
    git branch -M main
    
    cat > .gitignore << 'EOF'
.DS_Store
# Sync log files only (keep scripts!)
.sync/*.log
.sync/.sync.lock
.sync/.conflict
.obsidian/workspace*
.obsidian/cache
.trash/
*.tmp
*.swp
*~
EOF
    
    git add .
    git -c commit.gpgsign=false commit -m "Initial commit of wiki"
fi

# STEP 1: TRIGGER ICLOUD SYNC (for iCloud repos only)
trigger_icloud_sync

# STEP 2: COMMIT LOCAL CHANGES FIRST (preserve iPhone edits!)
git add -A
if ! git diff --staged --quiet; then
    COMMIT_MSG="Auto-sync from $PLATFORM: $(date '+%Y-%m-%d %H:%M:%S')"
    if git -c commit.gpgsign=false commit -m "$COMMIT_MSG" --quiet; then
        log_message "Committed changes: $COMMIT_MSG"
    else
        log_message "Commit failed"
    fi
fi

# STEP 3: CHECK FOR REMOTE
HAS_REMOTE=false
if git remote get-url origin &>/dev/null; then
    HAS_REMOTE=true
fi

# STEP 4: IF REMOTE EXISTS, SYNC WITH IT
if [ "$HAS_REMOTE" = true ]; then
    # Fetch to see what's on remote
    if git fetch origin main --quiet 2>/dev/null; then
        LOCAL=$(git rev-parse main 2>/dev/null)
        REMOTE=$(git rev-parse origin/main 2>/dev/null)
        
        if [ "$LOCAL" != "$REMOTE" ]; then
            # We need to sync
            BASE=$(git merge-base main origin/main 2>/dev/null)
            
            if [ "$LOCAL" = "$BASE" ]; then
                # We're behind - fast forward
                if git pull --ff-only origin main --quiet 2>/dev/null; then
                    log_message "Fast-forwarded to remote"
                fi
            else
                # We've diverged - need to merge or rebase
                # Try rebase first (cleaner history)
                if git pull --rebase origin main --quiet 2>/dev/null; then
                    log_message "Rebased onto remote"
                else
                    # Rebase failed, try merge
                    git rebase --abort 2>/dev/null
                    if git pull --no-rebase origin main --quiet 2>/dev/null; then
                        log_message "Merged with remote"
                    else
                        log_message "Sync failed - manual intervention needed"
                        send_notification "Wiki Sync Conflict" "Unable to sync with remote" "critical"
                        touch "$CONFLICT_FLAG"
                    fi
                fi
            fi
        fi
        
        # Push our changes
        if git push origin main --quiet 2>/dev/null; then
            log_message "Pushed changes to remote"
        else
            log_message "Push failed - will retry next sync"
        fi
    else
        log_message "Failed to fetch from remote"
    fi
fi

# Check for conflicts
if [ -f "$CONFLICT_FLAG" ]; then
    if [ -z "$(git diff --name-only --diff-filter=U)" ]; then
        rm -f "$CONFLICT_FLAG"
        log_message "Conflicts have been resolved"
        send_notification "Wiki Sync" "All conflicts have been resolved" "normal"
    fi
fi

# Cleanup old log entries (keep last 1000 lines)
for logfile in "$SYNC_LOG" "$WIKI_DIR/.sync/notifications.log"; do
    if [ -f "$logfile" ] && [ $(wc -l < "$logfile") -gt 1000 ]; then
        tail -n 1000 "$logfile" > "$logfile.tmp"
        mv "$logfile.tmp" "$logfile"
    fi
done