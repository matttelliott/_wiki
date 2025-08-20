#!/bin/bash

# sync.sh - Simple bidirectional wiki sync
# Supports macOS (local + iCloud), Linux, and other platforms
# Each machine gets a unique identifier in commits

# Configuration
LOCAL_WIKI="$HOME/_wiki"
LOG_DIR="$LOCAL_WIKI/.sync"
LOCK_FILE="$LOG_DIR/.sync.lock"

# Get unique machine identifier (hostname without domain)
MACHINE_NAME=$(hostname -s 2>/dev/null || hostname | cut -d'.' -f1)

# Platform-specific paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS has both local and iCloud
    ICLOUD_WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki"
else
    # Linux and others only have local
    ICLOUD_WIKI=""
fi

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Simple lock to prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE")
    if ps -p "$pid" > /dev/null 2>&1; then
        exit 0  # Already running
    fi
    rm -f "$LOCK_FILE"  # Stale lock
fi
echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Function to sync a single repository
sync_repo() {
    local repo_path="$1"
    local repo_name="$2"
    local is_icloud="$3"
    
    # Trigger iCloud download if needed (macOS only)
    if [ "$is_icloud" = "true" ] && [[ "$OSTYPE" == "darwin"* ]]; then
        find "$repo_path" -type f -name "*.md" -exec head -c 1 {} \; > /dev/null 2>&1
        sleep 2
    fi
    
    # Determine platform identifier
    # Format: hostname-OS-location (e.g., "macbook-macos-local" or "server1-linux")
    local platform="${MACHINE_NAME}"
    
    # Add OS type
    if [[ "$OSTYPE" == "darwin"* ]]; then
        platform="${platform}-macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        platform="${platform}-linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        platform="${platform}-windows"
    else
        platform="${platform}-unknown"
    fi
    
    # Add location for iCloud repos
    if [[ "$repo_path" == *"iCloud"* ]]; then
        platform="${platform}-icloud"
    fi
    
    # For iCloud, we can't CD due to macOS security - use git -C instead
    if [[ "$repo_path" == *"iCloud"* ]]; then
        # Stage and commit any changes
        if ! git -C "$repo_path" diff --quiet || ! git -C "$repo_path" diff --cached --quiet || [ -n "$(git -C "$repo_path" ls-files --others --exclude-standard)" ]; then
            git -C "$repo_path" add -A
            git -C "$repo_path" -c commit.gpgsign=false commit -m "Auto-sync from $platform: $(date '+%Y-%m-%d %H:%M:%S')" > /dev/null 2>&1
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Committed changes" >> "$LOG_DIR/sync.log"
        fi
        
        # Try to fetch and merge
        if git -C "$repo_path" fetch origin main 2>/tmp/icloud-fetch-error.log; then
            # Check if we need to merge
            local_rev=$(git -C "$repo_path" rev-parse HEAD)
            remote_rev=$(git -C "$repo_path" rev-parse origin/main)
            
            if [ "$local_rev" != "$remote_rev" ]; then
                # Try fast-forward or rebase
                if git -C "$repo_path" merge --ff-only origin/main > /dev/null 2>&1; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Fast-forwarded to remote" >> "$LOG_DIR/sync.log"
                elif git -C "$repo_path" rebase origin/main > /dev/null 2>&1; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Rebased onto remote" >> "$LOG_DIR/sync.log"
                else
                    # Conflict - preserve in branch and reset
                    conflict_branch="conflict-${MACHINE_NAME}-$(date +%Y%m%d-%H%M%S)"
                    git -C "$repo_path" rebase --abort > /dev/null 2>&1
                    git -C "$repo_path" branch "$conflict_branch"
                    git -C "$repo_path" reset --hard origin/main
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Conflict preserved in branch: $conflict_branch" >> "$LOG_DIR/sync.log"
                fi
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Failed to fetch from remote" >> "$LOG_DIR/sync.log"
        fi
        
        # Push changes
        if git -C "$repo_path" push origin main > /dev/null 2>&1; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Pushed to remote" >> "$LOG_DIR/sync.log"
        fi
    else
        # For local repos, we can CD normally
        cd "$repo_path" || return 1
        
        # Stage and commit any changes
        if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
            git add -A
            git -c commit.gpgsign=false commit -m "Auto-sync from $platform: $(date '+%Y-%m-%d %H:%M:%S')" > /dev/null 2>&1
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Committed changes" >> "$LOG_DIR/sync.log"
        fi
        
        # Try to fetch and merge
        if git fetch origin main > /dev/null 2>&1; then
            # Check if we need to merge
            local_rev=$(git rev-parse HEAD)
            remote_rev=$(git rev-parse origin/main)
            
            if [ "$local_rev" != "$remote_rev" ]; then
                # Try fast-forward or rebase
                if git merge --ff-only origin/main > /dev/null 2>&1; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Fast-forwarded to remote" >> "$LOG_DIR/sync.log"
                elif git rebase origin/main > /dev/null 2>&1; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Rebased onto remote" >> "$LOG_DIR/sync.log"
                else
                    # Conflict - preserve in branch and reset
                    conflict_branch="conflict-${MACHINE_NAME}-$(date +%Y%m%d-%H%M%S)"
                    git rebase --abort > /dev/null 2>&1
                    git branch "$conflict_branch"
                    git reset --hard origin/main
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Conflict preserved in branch: $conflict_branch" >> "$LOG_DIR/sync.log"
                fi
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Failed to fetch from remote" >> "$LOG_DIR/sync.log"
        fi
        
        # Push changes
        if git push origin main > /dev/null 2>&1; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$platform] Pushed to remote" >> "$LOG_DIR/sync.log"
        fi
    fi
}

# Main sync logic
if [ -n "$ICLOUD_WIKI" ] && [ -d "$ICLOUD_WIKI" ]; then
    # macOS with iCloud - bidirectional sync
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting bidirectional sync on $MACHINE_NAME" >> "$LOG_DIR/bidirectional.log"
    
    # Phase 1: Both repos commit and push
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Phase 1: Pushing changes..." >> "$LOG_DIR/bidirectional.log"
    sync_repo "$LOCAL_WIKI" "local" "false" &
    local_pid=$!
    sync_repo "$ICLOUD_WIKI" "icloud" "true" &
    icloud_pid=$!
    
    wait $local_pid 2>/dev/null
    wait $icloud_pid 2>/dev/null
    sleep 2
    
    # Phase 2: Both repos pull
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Phase 2: Pulling changes..." >> "$LOG_DIR/bidirectional.log"
    sync_repo "$LOCAL_WIKI" "local" "false" &
    local_pid=$!
    sync_repo "$ICLOUD_WIKI" "icloud" "true" &
    icloud_pid=$!
    
    wait $local_pid 2>/dev/null
    wait $icloud_pid 2>/dev/null
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Bidirectional sync complete" >> "$LOG_DIR/bidirectional.log"
else
    # Linux or macOS without iCloud - simple sync
    sync_repo "$LOCAL_WIKI" "local" "false"
fi

# Cleanup old logs (keep last 500 lines)
for log in "$LOG_DIR"/*.log; do
    if [ -f "$log" ] && [ $(wc -l < "$log" 2>/dev/null || echo 0) -gt 500 ]; then
        tail -n 500 "$log" > "$log.tmp"
        mv "$log.tmp" "$log"
    fi
done