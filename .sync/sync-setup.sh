#!/bin/bash

# sync-setup.sh - Set up automatic wiki syncing
# Works on macOS (launchd), Linux (systemd or cron)

WIKI_DIR="$HOME/_wiki"
SYNC_SCRIPT="$WIKI_DIR/.sync/sync.sh"
MACHINE_NAME=$(hostname -s 2>/dev/null || hostname | cut -d'.' -f1)

echo "Setting up wiki sync on $MACHINE_NAME..."

# Make sync script executable
chmod +x "$SYNC_SCRIPT"

# Platform-specific setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use launchd
    PLIST_FILE="$HOME/Library/LaunchAgents/com.user.wiki-sync.plist"
    
    echo "Setting up launchd service for macOS..."
    
    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.wiki-sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SYNC_SCRIPT</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/wiki-sync.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/wiki-sync.error.log</string>
</dict>
</plist>
EOF
    
    # Unload if already loaded, then load
    launchctl unload "$PLIST_FILE" 2>/dev/null
    launchctl load "$PLIST_FILE"
    
    echo "✓ Launchd service installed and started"
    echo "  Service name: com.user.wiki-sync"
    echo "  Runs every: 5 minutes"
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - offer both systemd and cron
    echo "Choose scheduler for Linux:"
    echo "1) systemd (recommended for modern systems)"
    echo "2) cron (traditional, works everywhere)"
    read -p "Choice [1]: " choice
    choice=${choice:-1}
    
    if [ "$choice" = "1" ] && command -v systemctl &> /dev/null; then
        # systemd setup
        echo "Setting up systemd timer..."
        
        SERVICE_FILE="$HOME/.config/systemd/user/wiki-sync.service"
        TIMER_FILE="$HOME/.config/systemd/user/wiki-sync.timer"
        
        mkdir -p "$HOME/.config/systemd/user"
        
        # Create service file
        cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Wiki Auto Sync
After=network-online.target

[Service]
Type=oneshot
ExecStart=$SYNC_SCRIPT
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
        
        # Create timer file
        cat > "$TIMER_FILE" << EOF
[Unit]
Description=Run Wiki Sync every 5 minutes
Requires=wiki-sync.service

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
EOF
        
        # Enable and start
        systemctl --user daemon-reload
        systemctl --user enable wiki-sync.timer
        systemctl --user start wiki-sync.timer
        
        echo "✓ Systemd timer installed and started"
        echo "  Check status: systemctl --user status wiki-sync.timer"
        echo "  View logs: journalctl --user -u wiki-sync"
        
    else
        # Cron setup (fallback or choice 2)
        echo "Setting up cron job..."
        
        # Remove old cron job if exists
        crontab -l 2>/dev/null | grep -v "$SYNC_SCRIPT" | crontab -
        
        # Add new cron job
        (crontab -l 2>/dev/null; echo "*/5 * * * * $SYNC_SCRIPT") | crontab -
        
        echo "✓ Cron job installed"
        echo "  Runs every: 5 minutes"
        echo "  Check with: crontab -l"
    fi
    
else
    echo "Platform not fully supported. You can manually add to cron:"
    echo "  */5 * * * * $SYNC_SCRIPT"
fi

# Test sync
echo ""
echo "Testing sync..."
if "$SYNC_SCRIPT"; then
    echo "✓ Sync test successful"
else
    echo "✗ Sync test failed - check configuration"
    exit 1
fi

echo ""
echo "Setup complete! Your wiki will sync automatically every 5 minutes."
echo "Check status with: $WIKI_DIR/.sync/sync-status.sh"