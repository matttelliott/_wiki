#!/bin/bash

# Cross-platform Setup Script for Wiki Synchronization
# Works on macOS and Linux

WIKI_DIR="${WIKI_DIR:-$HOME/_wiki}"
SCRIPT_DIR="$WIKI_DIR/.sync"

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
else
    echo "Unsupported platform: $OSTYPE"
    exit 1
fi

echo "Setting up Wiki Sync System for $PLATFORM..."
echo ""

# Make scripts executable
chmod +x "$SCRIPT_DIR/wiki-auto-sync.sh"
chmod +x "$SCRIPT_DIR/setup-sync.sh"

# Initialize git if needed
cd "$WIKI_DIR"
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    git branch -M main
    echo "✓ Git repository initialized"
fi

# Platform-specific setup
if [ "$PLATFORM" = "macos" ]; then
    echo "=== macOS Setup ==="
    
    # 1. Set up launchd service
    echo "Creating launchd service for auto-sync..."
    
    PLIST_FILE="$HOME/Library/LaunchAgents/com.user.wiki-sync.plist"
    
    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.wiki-sync</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_DIR/wiki-auto-sync.sh</string>
    </array>
    
    <key>StartInterval</key>
    <integer>300</integer> <!-- Run every 5 minutes -->
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>StandardOutPath</key>
    <string>$SCRIPT_DIR/sync-stdout.log</string>
    
    <key>StandardErrorPath</key>
    <string>$SCRIPT_DIR/sync-stderr.log</string>
    
    <key>WorkingDirectory</key>
    <string>$WIKI_DIR</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF
    
    # Load the service
    launchctl unload "$PLIST_FILE" 2>/dev/null
    launchctl load "$PLIST_FILE"
    echo "✓ Auto-sync service installed (runs every 5 minutes)"
    
    # 2. Check for iCloud
    ICLOUD_OBSIDIAN="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    if [ -d "$ICLOUD_OBSIDIAN" ]; then
        if [ ! -e "$ICLOUD_OBSIDIAN/Wiki" ]; then
            ln -s "$WIKI_DIR" "$ICLOUD_OBSIDIAN/Wiki"
            echo "✓ Wiki linked to iCloud for iOS access"
        else
            echo "✓ Wiki already linked to iCloud"
        fi
    else
        echo "⚠ iCloud Obsidian not found (install Obsidian on iOS to enable)"
    fi
    
    # 3. Check for fswatch
    if command -v fswatch &> /dev/null; then
        echo "✓ fswatch found (immediate sync available)"
        echo "  To enable: Run 'fswatch -o $WIKI_DIR | xargs -n1 $SCRIPT_DIR/wiki-auto-sync.sh'"
    else
        echo "⚠ fswatch not installed (install with: brew install fswatch)"
    fi
    
elif [ "$PLATFORM" = "linux" ]; then
    echo "=== Linux Setup ==="
    
    # 1. Set up systemd service
    echo "Setting up systemd service..."
    
    SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_USER_DIR"
    
    # Copy service files
    cp "$SCRIPT_DIR/linux-systemd/wiki-sync.service" "$SYSTEMD_USER_DIR/"
    cp "$SCRIPT_DIR/linux-systemd/wiki-sync.timer" "$SYSTEMD_USER_DIR/"
    
    # Update paths in service file
    sed -i "s|/home/%u|$HOME|g" "$SYSTEMD_USER_DIR/wiki-sync.service"
    
    # Reload systemd and enable services
    systemctl --user daemon-reload
    systemctl --user enable wiki-sync.timer
    systemctl --user start wiki-sync.timer
    
    echo "✓ Systemd timer installed (runs every 5 minutes)"
    
    # 2. Check for inotify-tools
    if command -v inotifywait &> /dev/null; then
        echo "✓ inotify-tools found (file watching available)"
        
        # Create watcher service
        cat > "$SYSTEMD_USER_DIR/wiki-watch.service" << EOF
[Unit]
Description=Wiki File Watcher
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'inotifywait -m -r -e modify,create,delete,move --exclude ".git|.sync" $HOME/_wiki | while read; do $HOME/_wiki/.sync/wiki-auto-sync.sh; done'
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF
        
        systemctl --user enable wiki-watch.service
        systemctl --user start wiki-watch.service
        echo "✓ File watcher service installed (immediate sync on changes)"
    else
        echo "⚠ inotify-tools not installed"
        echo "  Install with: sudo apt-get install inotify-tools (Debian/Ubuntu)"
        echo "              sudo dnf install inotify-tools (Fedora)"
        echo "              sudo pacman -S inotify-tools (Arch)"
    fi
    
    # 3. Check for notification support
    if command -v notify-send &> /dev/null; then
        echo "✓ Desktop notifications enabled"
    else
        echo "⚠ notify-send not found (install libnotify for desktop notifications)"
    fi
fi

# Create sync status script
cat > "$SCRIPT_DIR/sync-status.sh" << 'EOF'
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
        echo "  ✓ Auto-sync service is running"
    else
        echo "  ✗ Auto-sync service is not running"
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
EOF

chmod +x "$SCRIPT_DIR/sync-status.sh"

echo ""
echo "========================================="
echo "✅ Setup Complete for $PLATFORM!"
echo "========================================="
echo ""

# Run status check
"$SCRIPT_DIR/sync-status.sh"

echo ""
echo "📋 Next Steps:"
echo "----------------------------------------"
echo "1. Configure git remote (when server is ready):"
echo "   cd $WIKI_DIR"
echo "   git remote add origin [your-git-url]"
echo "   git push -u origin main"
echo ""
echo "2. Test the sync:"
echo "   $SCRIPT_DIR/wiki-auto-sync.sh"
echo ""
echo "3. Check status anytime:"
echo "   $SCRIPT_DIR/sync-status.sh"
echo ""

if [ "$PLATFORM" = "linux" ]; then
    echo "4. View systemd logs:"
    echo "   journalctl --user -u wiki-sync.service"
    echo "   journalctl --user -u wiki-watch.service"
elif [ "$PLATFORM" = "macos" ]; then
    echo "4. View launchd logs:"
    echo "   tail -f $SCRIPT_DIR/sync-stdout.log"
fi

echo ""
echo "⚠ Important: Both machines will:"
echo "  • Auto-commit every 5 minutes"
echo "  • Pull before pushing (fetch upstream changes)"
echo "  • Notify on conflicts"
echo "  • Auto-resolve simple conflicts"