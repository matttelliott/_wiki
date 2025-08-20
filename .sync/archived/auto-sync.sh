#!/bin/bash

# auto-sync.sh - Generic Git Auto-Sync Script
#
# A reusable script for auto-syncing any git repository
# Perfect for dotfiles, wikis, notes, or any frequently-changing repos
#
# FEATURES:
# - Commits before pulling (preserves local changes)
# - Handles merge conflicts gracefully
# - Platform detection for meaningful commit messages
# - Lock file prevents concurrent runs
# - Optional notifications for conflicts
# - Works with any git remote
#
# USAGE:
#   /bin/bash auto-sync.sh [options]
#
# OPTIONS:
#   -d, --dir PATH       Repository directory (default: current directory)
#   -m, --message MSG    Custom commit message prefix (default: "Auto-sync")
#   -n, --notify         Enable desktop notifications for conflicts
#   -i, --icloud         Enable iCloud mode (reads files before sync)
#   -l, --log PATH       Custom log file path (default: .sync/sync.log)
#   -q, --quiet          Suppress output
#   -h, --help           Show this help message
#
# EXAMPLES:
#   # Sync current directory
#   auto-sync.sh
#
#   # Sync dotfiles with custom message
#   auto-sync.sh -d ~/dotfiles -m "Config update"
#
#   # Sync with notifications
#   auto-sync.sh -d ~/notes -n
#
#   # Use in crontab (every 5 minutes)
#   */5 * * * * /path/to/auto-sync.sh -d ~/myrepo -q

# Parse command line arguments
REPO_DIR="$(pwd)"
COMMIT_PREFIX="Auto-sync"
ENABLE_NOTIFY=false
ENABLE_ICLOUD=false
LOG_FILE=""
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            REPO_DIR="$2"
            shift 2
            ;;
        -m|--message)
            COMMIT_PREFIX="$2"
            shift 2
            ;;
        -n|--notify)
            ENABLE_NOTIFY=true
            shift
            ;;
        -i|--icloud)
            ENABLE_ICLOUD=true
            shift
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -h|--help)
            grep "^#" "$0" | grep -E "^# [A-Z]|^# EXAMPLES:" | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set up paths
REPO_DIR="$(cd "$REPO_DIR" && pwd)" # Absolute path
SYNC_DIR="$REPO_DIR/.sync"
LOG_FILE="${LOG_FILE:-$SYNC_DIR/sync.log}"
LOCK_FILE="$SYNC_DIR/.sync.lock"
CONFLICT_FLAG="$SYNC_DIR/.conflict"

# Ensure sync directory exists
mkdir -p "$SYNC_DIR"

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    PLATFORM="windows"
else
    PLATFORM="unknown"
fi

# Auto-detect iCloud if path contains iCloud markers
if [[ "$REPO_DIR" == *"iCloud"* ]] || [[ "$REPO_DIR" == *"Mobile Documents"* ]]; then
    ENABLE_ICLOUD=true
    PLATFORM="icloud"
fi

# Logging function
log_message() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [$PLATFORM] $1"
    echo "$msg" >> "$LOG_FILE"
    if [ "$QUIET" = false ]; then
        echo "$msg"
    fi
}

# Notification function
send_notification() {
    if [ "$ENABLE_NOTIFY" = false ]; then
        return
    fi
    
    local title="$1"
    local message="$2"
    
    if [[ "$PLATFORM" == "macos" ]]; then
        osascript -e "display notification \"$message\" with title \"$title\""
    elif [[ "$PLATFORM" == "linux" ]]; then
        if command -v notify-send &> /dev/null; then
            notify-send "$title" "$message"
        fi
    elif [[ "$PLATFORM" == "windows" ]]; then
        # Windows notification via PowerShell
        powershell -Command "New-BurntToastNotification -Text '$title', '$message'" 2>/dev/null || true
    fi
}

# iCloud sync trigger
trigger_icloud_sync() {
    if [ "$ENABLE_ICLOUD" = false ]; then
        return
    fi
    
    log_message "Triggering iCloud file sync..."
    
    # Read files to trigger iCloud download
    find "$REPO_DIR" -type f \
        -not -path "*/\.git/*" \
        -not -path "*/\.sync/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/.DS_Store" \
        2>/dev/null | while read -r file; do
        head -n 1 "$file" > /dev/null 2>&1
    done
    
    sleep 2 # Give iCloud time to sync
}

# Check for lock file
if [ -f "$LOCK_FILE" ]; then
    # Remove stale lock (older than 5 minutes)
    if [[ $(find "$LOCK_FILE" -mmin +5 2>/dev/null) ]]; then
        log_message "Removing stale lock file"
        rm -f "$LOCK_FILE"
    else
        exit 0 # Another sync is running
    fi
fi

# Create lock file
touch "$LOCK_FILE"

# Cleanup on exit
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# Change to repository directory
cd "$REPO_DIR" || {
    log_message "ERROR: Cannot access directory $REPO_DIR"
    exit 1
}

# Check if this is a git repository
if [ ! -d .git ]; then
    log_message "ERROR: $REPO_DIR is not a git repository"
    exit 1
fi

# Trigger iCloud sync if needed
trigger_icloud_sync

# Stage all changes
git add -A

# Commit if there are changes
if ! git diff --staged --quiet; then
    COMMIT_MSG="$COMMIT_PREFIX from $PLATFORM: $(date '+%Y-%m-%d %H:%M:%S')"
    if git -c commit.gpgsign=false commit -m "$COMMIT_MSG" --quiet; then
        log_message "Committed: $COMMIT_MSG"
    else
        log_message "Commit failed"
    fi
fi

# Check for remote
if ! git remote get-url origin &>/dev/null; then
    log_message "No remote origin configured, skipping sync"
    exit 0
fi

# Get default branch name
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
    # Try common branch names
    for branch in main master; do
        if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            DEFAULT_BRANCH="$branch"
            break
        fi
    done
fi

if [ -z "$DEFAULT_BRANCH" ]; then
    log_message "Cannot determine default branch"
    exit 1
fi

# Fetch from remote
if git fetch origin "$DEFAULT_BRANCH" --quiet 2>/dev/null; then
    LOCAL=$(git rev-parse HEAD 2>/dev/null)
    REMOTE=$(git rev-parse "origin/$DEFAULT_BRANCH" 2>/dev/null)
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        BASE=$(git merge-base HEAD "origin/$DEFAULT_BRANCH" 2>/dev/null)
        
        if [ "$LOCAL" = "$BASE" ]; then
            # We're behind - fast forward
            if git pull --ff-only origin "$DEFAULT_BRANCH" --quiet 2>/dev/null; then
                log_message "Fast-forwarded to remote"
            fi
        else
            # We've diverged - try rebase then merge
            if git pull --rebase origin "$DEFAULT_BRANCH" --quiet 2>/dev/null; then
                log_message "Rebased onto remote"
            else
                git rebase --abort 2>/dev/null
                if git pull --no-rebase origin "$DEFAULT_BRANCH" --quiet 2>/dev/null; then
                    log_message "Merged with remote"
                else
                    log_message "CONFLICT: Manual intervention needed"
                    send_notification "Git Sync Conflict" "Repository: $REPO_DIR"
                    touch "$CONFLICT_FLAG"
                fi
            fi
        fi
    fi
    
    # Push changes
    if git push origin HEAD:"$DEFAULT_BRANCH" --quiet 2>/dev/null; then
        log_message "Pushed to remote"
    else
        log_message "Push failed - will retry next sync"
    fi
else
    log_message "Failed to fetch from remote"
fi

# Check if conflicts were resolved
if [ -f "$CONFLICT_FLAG" ]; then
    if [ -z "$(git diff --name-only --diff-filter=U)" ]; then
        rm -f "$CONFLICT_FLAG"
        log_message "Conflicts resolved"
        send_notification "Git Sync" "Conflicts resolved: $REPO_DIR"
    fi
fi

# Cleanup old log entries (keep last 1000 lines)
if [ -f "$LOG_FILE" ] && [ $(wc -l < "$LOG_FILE" 2>/dev/null || echo 0) -gt 1000 ]; then
    tail -n 1000 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi