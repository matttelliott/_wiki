#!/bin/bash

# sync-status.sh - Check status of auto-sync services
# Works with the new generic auto-sync system

echo "=== Wiki Auto-Sync Status ==="
echo ""

# Function to check repo status
check_repo() {
    local repo_path="$1"
    local repo_name="$2"
    
    echo "📁 $repo_name: $repo_path"
    
    if [ ! -d "$repo_path" ]; then
        echo "   ❌ Repository not found"
        return
    fi
    
    cd "$repo_path" || return
    
    # Git status
    if [ -d .git ]; then
        # Check for uncommitted changes
        if ! git diff --quiet || ! git diff --staged --quiet; then
            echo "   ⚠️  Uncommitted changes present"
        else
            echo "   ✅ Working tree clean"
        fi
        
        # Check sync with remote
        if git remote get-url origin &>/dev/null; then
            git fetch origin &>/dev/null 2>&1
            LOCAL=$(git rev-parse HEAD 2>/dev/null)
            REMOTE=$(git rev-parse @{u} 2>/dev/null)
            BASE=$(git merge-base HEAD @{u} 2>/dev/null)
            
            if [ "$LOCAL" = "$REMOTE" ]; then
                echo "   ✅ In sync with remote"
            elif [ "$LOCAL" = "$BASE" ]; then
                echo "   ⬇️  Behind remote (needs pull)"
            elif [ "$REMOTE" = "$BASE" ]; then
                echo "   ⬆️  Ahead of remote (needs push)"
            else
                echo "   🔄 Diverged from remote"
            fi
        else
            echo "   ⚠️  No remote configured"
        fi
        
        # Check for conflicts
        if [ -f "$repo_path/.sync/.conflict" ]; then
            echo "   ⚠️  CONFLICTS need resolution"
        fi
    else
        echo "   ❌ Not a git repository"
    fi
    
    # Check log
    if [ -f "$repo_path/.sync/sync.log" ]; then
        last_sync=$(tail -n 1 "$repo_path/.sync/sync.log" 2>/dev/null | cut -d' ' -f1-3)
        if [ -n "$last_sync" ]; then
            echo "   📝 Last sync: $last_sync"
        fi
    fi
    
    echo ""
}

# Check services
echo "🔧 Services:"
echo ""

# macOS services
if [[ "$OSTYPE" == "darwin"* ]]; then
    for service in wiki-local wiki-icloud; do
        if launchctl list | grep -q "com.user.$service"; then
            status=$(launchctl list | grep "com.user.$service" | awk '{print $1}')
            if [ "$status" = "-" ]; then
                echo "✅ com.user.$service: Running"
            else
                echo "⚠️  com.user.$service: Exit code $status"
            fi
        else
            echo "❌ com.user.$service: Not loaded"
        fi
    done
fi

# Linux services
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if systemctl --user list-timers | grep -q wiki; then
        systemctl --user status wiki-*.timer --no-pager | grep -E "wiki-.*\.timer|Active:"
    else
        # Check cron
        if crontab -l 2>/dev/null | grep -q auto-sync; then
            echo "✅ Cron job configured"
        else
            echo "❌ No sync service found"
        fi
    fi
fi

echo ""
echo "=== Repository Status ==="
echo ""

# Check local wiki
check_repo "$HOME/_wiki" "Local Wiki"

# Check iCloud wiki
check_repo "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki" "iCloud Wiki"

# Recent sync activity
echo "=== Recent Activity ==="
echo ""

if [ -f "$HOME/_wiki/.sync/sync.log" ]; then
    echo "Local wiki (last 5 syncs):"
    tail -n 5 "$HOME/_wiki/.sync/sync.log" | sed 's/^/  /'
    echo ""
fi

if [ -f "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki/.sync/sync.log" ]; then
    echo "iCloud wiki (last 5 syncs):"
    tail -n 5 "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki/.sync/sync.log" 2>/dev/null | sed 's/^/  /'
    echo ""
fi

# Commands reminder
echo "=== Useful Commands ==="
echo ""
echo "Manual sync:"
echo "  Local:  ~/.sync/auto-sync.sh -d ~/_wiki"
echo "  iCloud: ~/.sync/auto-sync.sh -d ~/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents/Wiki -i"
echo ""
echo "Service control:"
echo "  Stop all:   launchctl unload ~/Library/LaunchAgents/com.user.wiki-*.plist"
echo "  Start all:  launchctl load ~/Library/LaunchAgents/com.user.wiki-*.plist"
echo ""
echo "View logs:"
echo "  tail -f ~/.sync/sync.log"