#!/bin/bash

# Cross-platform Wiki Auto-Sync Script
# Works on macOS and Linux
# Automatically commits changes and syncs with remote

WIKI_DIR="${WIKI_DIR:-$HOME/_wiki}"
SYNC_LOG="$WIKI_DIR/.sync/sync.log"
LOCK_FILE="$WIKI_DIR/.sync/.sync.lock"
CONFLICT_FLAG="$WIKI_DIR/.sync/.conflict"

# Ensure log directory exists
mkdir -p "$WIKI_DIR/.sync"

# Detect platform
if [[ "$WIKI_DIR" == *"iCloud~md~obsidian"* ]]; then
    PLATFORM="icloud"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
else
    PLATFORM="unknown"
fi

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$PLATFORM] $1" >> "$SYNC_LOG"
}

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"  # normal, critical
    
    if [[ "$PLATFORM" == "macos" ]]; then
        # macOS notification
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"Submarine\""
    elif [[ "$PLATFORM" == "linux" ]]; then
        # Linux notification (requires libnotify)
        if command -v notify-send &> /dev/null; then
            notify-send --urgency="$urgency" "$title" "$message"
        fi
    fi
    
    # Also log to file for external monitoring
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] NOTIFICATION: $title - $message" >> "$WIKI_DIR/.sync/notifications.log"
}

# Check for lock file to prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
    # Check if lock is stale (older than 5 minutes)
    if [[ $(find "$LOCK_FILE" -mmin +5 2>/dev/null) ]]; then
        log_message "Removing stale lock file"
        rm -f "$LOCK_FILE"
    else
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
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
.DS_Store
.sync/
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

# Check if remote is configured
HAS_REMOTE=false
if git remote get-url origin &>/dev/null; then
    HAS_REMOTE=true
fi

# Function to handle merge conflicts
handle_conflicts() {
    local conflict_files=$(git diff --name-only --diff-filter=U)
    
    if [ -n "$conflict_files" ]; then
        log_message "CONFLICT detected in files: $conflict_files"
        
        # Create conflict report
        cat > "$CONFLICT_FLAG" << EOF
Conflict detected at $(date '+%Y-%m-%d %H:%M:%S')
Affected files:
$conflict_files

To resolve:
1. Edit the conflicted files
2. git add <files>
3. git commit
4. rm $CONFLICT_FLAG
EOF
        
        # Send notification
        send_notification "Wiki Sync Conflict" "Merge conflict detected. Check: $conflict_files" "critical"
        
        # Try auto-resolution for simple conflicts
        # This accepts "ours" for conflicts in auto-generated files
        for file in $conflict_files; do
            if [[ "$file" == *".sync/"* ]] || [[ "$file" == *".obsidian/"* ]]; then
                git checkout --ours "$file"
                git add "$file"
                log_message "Auto-resolved conflict in $file (kept local version)"
            fi
        done
        
        # Check if all conflicts were auto-resolved
        if [ -z "$(git diff --name-only --diff-filter=U)" ]; then
            git -c commit.gpgsign=false commit -m "Auto-resolved conflicts in system files"
            rm -f "$CONFLICT_FLAG"
            log_message "All conflicts auto-resolved"
        else
            return 1
        fi
    fi
    return 0
}

# If remote exists, pull first
if [ "$HAS_REMOTE" = true ]; then
    # Fetch remote changes
    git fetch origin main --quiet 2>/dev/null || {
        log_message "Failed to fetch from remote"
    }
    
    # Check if we're behind
    LOCAL=$(git rev-parse main 2>/dev/null)
    REMOTE=$(git rev-parse origin/main 2>/dev/null)
    BASE=$(git merge-base main origin/main 2>/dev/null)
    
    if [ "$LOCAL" != "$REMOTE" ] && [ "$LOCAL" = "$BASE" ]; then
        # We're behind, need to pull
        log_message "Pulling remote changes"
        
        # Stash local changes if any
        if ! git diff --quiet || ! git diff --staged --quiet; then
            git stash push -m "Auto-stash before pull $(date '+%Y-%m-%d %H:%M:%S')" --quiet
            STASHED=true
        fi
        
        # Pull with rebase
        if git pull --rebase origin main --quiet 2>/dev/null; then
            log_message "Successfully pulled remote changes"
            
            # Pop stash if we stashed
            if [ "$STASHED" = true ]; then
                if git stash pop --quiet 2>/dev/null; then
                    log_message "Reapplied local changes"
                else
                    log_message "Failed to reapply local changes - manual intervention needed"
                    send_notification "Wiki Sync Issue" "Failed to reapply local changes after pull" "critical"
                fi
            fi
        else
            # Rebase failed, try merge
            git rebase --abort 2>/dev/null
            
            if git pull origin main --no-rebase --quiet 2>/dev/null; then
                log_message "Pulled with merge (rebase failed)"
                handle_conflicts
            else
                log_message "Pull failed - manual intervention needed"
                send_notification "Wiki Sync Failed" "Unable to pull remote changes" "critical"
            fi
            
            # Pop stash if we stashed
            if [ "$STASHED" = true ]; then
                git stash pop --quiet 2>/dev/null || true
            fi
        fi
    fi
fi

# Stage all changes
git add -A

# Check if there are changes to commit
if ! git diff --staged --quiet; then
    # Commit with timestamp and platform
    COMMIT_MSG="Auto-sync from $PLATFORM: $(date '+%Y-%m-%d %H:%M:%S')"
    
    if git -c commit.gpgsign=false commit -m "$COMMIT_MSG" --quiet; then
        log_message "Committed changes: $COMMIT_MSG"
        
        # Push if remote exists
        if [ "$HAS_REMOTE" = true ]; then
            if git push origin main --quiet 2>/dev/null; then
                log_message "Pushed changes to remote"
            else
                # Push failed, might be due to remote changes
                log_message "Push failed, attempting to sync"
                
                # Pull and retry
                if git pull --rebase origin main --quiet 2>/dev/null; then
                    if git push origin main --quiet 2>/dev/null; then
                        log_message "Successfully synced after pull"
                    else
                        log_message "Push still failed after pull"
                        send_notification "Wiki Sync Issue" "Unable to push changes to remote" "critical"
                    fi
                else
                    git rebase --abort 2>/dev/null
                    git pull origin main --no-rebase --quiet 2>/dev/null
                    handle_conflicts
                fi
            fi
        fi
    else
        log_message "Commit failed"
    fi
fi

# Check for existing conflicts
if [ -f "$CONFLICT_FLAG" ]; then
    # Check if conflicts are resolved
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