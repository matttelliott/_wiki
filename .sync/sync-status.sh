#!/bin/bash

# sync-status.sh - Check status of wiki sync system

WIKI_DIR="$HOME/_wiki"
ICLOUD_WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki"
LOG_DIR="$WIKI_DIR/.sync"
MACHINE_NAME=$(hostname -s 2>/dev/null || hostname | cut -d'.' -f1)

echo "=== Wiki Sync Status on $MACHINE_NAME ==="
echo ""

# Check scheduler status
echo "📅 Scheduler Status:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - check launchd
    if launchctl list | grep -q "com.user.wiki-sync\|com.user.wiki-bidirectional"; then
        service_name=$(launchctl list | grep -E "com.user.wiki-(sync|bidirectional)" | awk '{print $3}')
        echo "  ✓ Launchd service active: $service_name"
    else
        echo "  ✗ No launchd service found"
        echo "    Run: $WIKI_DIR/.sync/sync-setup.sh"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - check both systemd and cron
    systemd_found=false
    cron_found=false
    
    if command -v systemctl &> /dev/null && systemctl --user list-timers 2>/dev/null | grep -q wiki-sync; then
        systemd_found=true
        echo "  ✓ Systemd timer active"
    fi
    
    if crontab -l 2>/dev/null | grep -q "$WIKI_DIR/.sync/sync.sh"; then
        cron_found=true
        echo "  ✓ Cron job active"
    fi
    
    if [ "$systemd_found" = false ] && [ "$cron_found" = false ]; then
        echo "  ✗ No scheduler found"
        echo "    Run: $WIKI_DIR/.sync/sync-setup.sh"
    fi
fi

echo ""
echo "📁 Repository Status:"

# Check local repo
if [ -d "$WIKI_DIR/.git" ]; then
    cd "$WIKI_DIR"
    branch=$(git branch --show-current 2>/dev/null)
    status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    
    echo "  Local ($WIKI_DIR):"
    echo "    Branch: $branch"
    echo "    Uncommitted changes: $status files"
    
    # Check if in sync with remote
    git fetch origin main &>/dev/null
    local_rev=$(git rev-parse HEAD 2>/dev/null)
    remote_rev=$(git rev-parse origin/main 2>/dev/null)
    
    if [ "$local_rev" = "$remote_rev" ]; then
        echo "    ✓ In sync with remote"
    else
        behind=$(git rev-list HEAD..origin/main --count 2>/dev/null)
        ahead=$(git rev-list origin/main..HEAD --count 2>/dev/null)
        echo "    ⚠ Behind: $behind commits, Ahead: $ahead commits"
    fi
else
    echo "  ✗ Local repo not found at $WIKI_DIR"
fi

# Check iCloud repo (macOS only)
if [[ "$OSTYPE" == "darwin"* ]] && [ -d "$ICLOUD_WIKI/.git" ]; then
    cd "$ICLOUD_WIKI"
    branch=$(git branch --show-current 2>/dev/null)
    status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    
    echo ""
    echo "  iCloud ($ICLOUD_WIKI):"
    echo "    Branch: $branch"
    echo "    Uncommitted changes: $status files"
    
    # Check if in sync with remote
    git fetch origin main &>/dev/null
    local_rev=$(git rev-parse HEAD 2>/dev/null)
    remote_rev=$(git rev-parse origin/main 2>/dev/null)
    
    if [ "$local_rev" = "$remote_rev" ]; then
        echo "    ✓ In sync with remote"
    else
        behind=$(git rev-list HEAD..origin/main --count 2>/dev/null)
        ahead=$(git rev-list origin/main..HEAD --count 2>/dev/null)
        echo "    ⚠ Behind: $behind commits, Ahead: $ahead commits"
    fi
fi

echo ""
echo "🌿 Conflict Branches:"
cd "$WIKI_DIR"
conflicts=$(git branch 2>/dev/null | grep conflict- | wc -l | tr -d ' ')
if [ "$conflicts" -gt 0 ]; then
    echo "  ⚠ $conflicts conflict branches found"
    git branch | grep conflict- | head -5 | sed 's/^/    /'
    if [ "$conflicts" -gt 5 ]; then
        echo "    ... and $((conflicts - 5)) more"
    fi
else
    echo "  ✓ No conflict branches"
fi

echo ""
echo "📊 Recent Sync Activity:"
if [ -f "$LOG_DIR/sync.log" ]; then
    last_5=$(tail -5 "$LOG_DIR/sync.log" 2>/dev/null)
    if [ -n "$last_5" ]; then
        echo "$last_5" | sed 's/^/  /'
    else
        echo "  No recent activity"
    fi
else
    echo "  No sync log found"
fi

echo ""
echo "💡 Commands:"
echo "  Manual sync: $WIKI_DIR/.sync/sync.sh"
echo "  View full log: tail -50 $LOG_DIR/sync.log"
if [ "$conflicts" -gt 0 ]; then
    echo "  Review conflicts: git branch | grep conflict-"
    echo "  Clean old conflicts: git branch | grep conflict- | xargs git branch -D"
fi