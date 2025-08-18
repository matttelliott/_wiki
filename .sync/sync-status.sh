#!/bin/bash

WIKI_DIR="${WIKI_DIR:-$HOME/_wiki}"

echo "=== Wiki Sync Status ==="
echo ""

# Platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="Linux"
else
    PLATFORM="Unknown"
fi
echo "Platform: $PLATFORM"
echo ""

# Git status
echo "Git Status:"
cd "$WIKI_DIR"
if [ -d .git ]; then
    echo "  Branch: $(git branch --show-current)"
    echo "  Last commit: $(git log -1 --format='%h %s (%ar)' 2>/dev/null || echo 'No commits yet')"
    echo "  Uncommitted changes: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') files"
    if git remote get-url origin &>/dev/null; then
        echo "  Remote: $(git remote get-url origin)"
        # Check sync status with remote
        git fetch origin main --quiet 2>/dev/null
        LOCAL=$(git rev-parse main 2>/dev/null)
        REMOTE=$(git rev-parse origin/main 2>/dev/null)
        if [ "$LOCAL" = "$REMOTE" ]; then
            echo "  Sync: ✓ Up to date with remote"
        elif [ "$LOCAL" = "$(git merge-base main origin/main 2>/dev/null)" ]; then
            echo "  Sync: ⟳ Behind remote (will pull on next sync)"
        else
            echo "  Sync: ⟳ Diverged from remote (will sync on next run)"
        fi
    else
        echo "  Remote: Not configured"
    fi
else
    echo "  Git not initialized"
fi

echo ""
echo "Sync Services:"

if [ "$PLATFORM" = "macOS" ]; then
    # Check launchd services
    if launchctl list | grep -q "com.user.wiki-sync"; then
        echo "  ✓ Auto-sync service is running (local)"
    else
        echo "  ✗ Auto-sync service is not running (local)"
    fi
    if launchctl list | grep -q "com.user.wiki-sync-icloud"; then
        echo "  ✓ Auto-sync service is running (iCloud)"
    else
        echo "  ✗ Auto-sync service is not running (iCloud)"
    fi
elif [ "$PLATFORM" = "Linux" ]; then
    # Check systemd services
    if systemctl --user is-active wiki-sync.timer &>/dev/null; then
        echo "  ✓ Auto-sync timer is active"
        echo "    Next run: $(systemctl --user status wiki-sync.timer | grep "Trigger:" | sed 's/.*Trigger: //')"
    else
        echo "  ✗ Auto-sync timer is not active"
    fi
    
    if systemctl --user is-active wiki-watch.service &>/dev/null; then
        echo "  ✓ File watcher is active"
    else
        echo "  ✗ File watcher is not active"
    fi
fi

# Check for conflicts
if [ -f "$WIKI_DIR/.sync/.conflict" ]; then
    echo ""
    echo "⚠ CONFLICT DETECTED:"
    cat "$WIKI_DIR/.sync/.conflict"
fi

echo ""
echo "Recent Sync Activity (last 10 entries):"
if [ -f "$WIKI_DIR/.sync/sync.log" ]; then
    tail -10 "$WIKI_DIR/.sync/sync.log"
else
    echo "  No sync log found"
fi

# Check notifications
if [ -f "$WIKI_DIR/.sync/notifications.log" ]; then
    echo ""
    echo "Recent Notifications:"
    tail -5 "$WIKI_DIR/.sync/notifications.log"
fi
