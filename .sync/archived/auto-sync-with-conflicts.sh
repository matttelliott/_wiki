#!/bin/bash

# auto-sync-with-conflicts.sh - Enhanced auto-sync that preserves conflicts
#
# Uses Conflict Branch Strategy:
# - On conflict, creates a branch to preserve both versions
# - Resets main to remote to continue syncing
# - Tracks conflicts for later review

# Inherit all functionality from auto-sync.sh
source "$(dirname "$0")/auto-sync.sh" 2>/dev/null || true

# Function to handle conflicts using branch strategy
handle_conflicts() {
    local repo_dir="$1"
    cd "$repo_dir" || return 1
    
    # Check for conflicts
    if [ -n "$(git diff --name-only --diff-filter=U)" ]; then
        local conflict_branch="conflict-$(date +%Y%m%d-%H%M%S)"
        local conflicted_files=$(git diff --name-only --diff-filter=U)
        
        log_message "CONFLICT detected in: $conflicted_files"
        
        # Stage all changes including conflicts
        git add -A
        
        # Commit the conflict state
        git -c commit.gpgsign=false commit -m "CONFLICT: Preserving both versions in $conflicted_files" --no-verify 2>/dev/null || true
        
        # Create branch to preserve this state
        git branch "$conflict_branch"
        log_message "Created branch $conflict_branch to preserve conflicts"
        
        # Track the conflict
        mkdir -p "$repo_dir/.sync/conflicts"
        cat > "$repo_dir/.sync/conflicts/$conflict_branch.txt" << EOF
Date: $(date)
Branch: $conflict_branch
Files: $conflicted_files
Status: pending
EOF
        
        # Reset to remote to continue syncing
        git reset --hard origin/main 2>/dev/null || git reset --hard origin/master 2>/dev/null
        log_message "Reset to remote version to continue syncing"
        
        # Notify about conflict
        send_notification "Wiki Sync Conflict" "Conflicts preserved in branch: $conflict_branch"
        
        return 0
    fi
    
    return 1
}

# Override the main sync logic to handle conflicts
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # Parse same arguments as auto-sync.sh
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
            *)
                shift
                ;;
        esac
    done

    # Set up paths
    REPO_DIR="$(cd "$REPO_DIR" && pwd)"
    SYNC_DIR="$REPO_DIR/.sync"
    LOG_FILE="${LOG_FILE:-$SYNC_DIR/sync.log}"
    
    # Ensure sync directory exists
    mkdir -p "$SYNC_DIR"
    
    # Source the logging functions
    log_message() {
        local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
        echo "$msg" >> "$LOG_FILE"
        if [ "$QUIET" = false ]; then
            echo "$msg"
        fi
    }
    
    send_notification() {
        if [ "$ENABLE_NOTIFY" = false ]; then
            return
        fi
        osascript -e "display notification \"$2\" with title \"$1\"" 2>/dev/null || true
    }
    
    cd "$REPO_DIR" || exit 1
    
    # Run standard auto-sync first
    "$REPO_DIR/.sync/auto-sync.sh" -d "$REPO_DIR" \
        $([ "$ENABLE_NOTIFY" = true ] && echo "-n") \
        $([ "$ENABLE_ICLOUD" = true ] && echo "-i") \
        $([ "$QUIET" = true ] && echo "-q") \
        -m "$COMMIT_PREFIX" 2>&1 | while read line; do
        if echo "$line" | grep -q "CONFLICT\|Automatic merge failed"; then
            # Conflict detected, handle it
            handle_conflicts "$REPO_DIR"
            
            # Try sync again after handling conflict
            "$REPO_DIR/.sync/auto-sync.sh" -d "$REPO_DIR" \
                $([ "$ENABLE_NOTIFY" = true ] && echo "-n") \
                $([ "$ENABLE_ICLOUD" = true ] && echo "-i") \
                $([ "$QUIET" = true ] && echo "-q") \
                -m "$COMMIT_PREFIX"
            break
        fi
    done
fi