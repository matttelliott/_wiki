#!/bin/bash

# install-auto-sync.sh - Install auto-sync for any git repository
#
# This script sets up automatic git syncing for any repository
# Works on macOS (launchd), Linux (systemd/cron), and Windows (Task Scheduler)
#
# USAGE:
#   curl -sSL https://raw.githubusercontent.com/yourusername/auto-sync/main/install.sh | bash -s -- [options]
#   OR
#   ./install-auto-sync.sh [options]
#
# OPTIONS:
#   -d, --dir PATH       Repository to sync (default: current directory)
#   -i, --interval MIN   Sync interval in minutes (default: 5)
#   -n, --name NAME      Service name (default: derived from directory)
#   --notify             Enable desktop notifications
#   --icloud             Enable iCloud mode
#   -h, --help           Show help

set -e

# Default values
REPO_DIR="$(pwd)"
INTERVAL=5
SERVICE_NAME=""
ENABLE_NOTIFY=false
ENABLE_ICLOUD=false
SCRIPT_URL="https://raw.githubusercontent.com/matttelliott/_wiki/main/.sync/auto-sync.sh"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            REPO_DIR="$2"
            shift 2
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -n|--name)
            SERVICE_NAME="$2"
            shift 2
            ;;
        --notify)
            ENABLE_NOTIFY=true
            shift
            ;;
        --icloud)
            ENABLE_ICLOUD=true
            shift
            ;;
        -h|--help)
            grep "^#" "$0" | grep -v "^#!/" | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Convert to absolute path
REPO_DIR="$(cd "$REPO_DIR" && pwd)"

# Generate service name if not provided
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME="auto-sync-$(basename "$REPO_DIR")"
fi

echo "Installing auto-sync for: $REPO_DIR"
echo "Service name: $SERVICE_NAME"
echo "Sync interval: $INTERVAL minutes"

# Create .sync directory
SYNC_DIR="$REPO_DIR/.sync"
mkdir -p "$SYNC_DIR"

# Download auto-sync script
echo "Downloading auto-sync script..."
if command -v curl &> /dev/null; then
    curl -sSL "$SCRIPT_URL" -o "$SYNC_DIR/auto-sync.sh"
elif command -v wget &> /dev/null; then
    wget -q "$SCRIPT_URL" -O "$SYNC_DIR/auto-sync.sh"
else
    echo "ERROR: Neither curl nor wget found. Please install one."
    exit 1
fi
chmod +x "$SYNC_DIR/auto-sync.sh"

# Build sync command
SYNC_CMD="$SYNC_DIR/auto-sync.sh -d '$REPO_DIR' -q"
if [ "$ENABLE_NOTIFY" = true ]; then
    SYNC_CMD="$SYNC_CMD -n"
fi
if [ "$ENABLE_ICLOUD" = true ]; then
    SYNC_CMD="$SYNC_CMD -i"
fi

# Platform-specific installation
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use launchd
    echo "Setting up launchd service..."
    
    PLIST_FILE="$HOME/Library/LaunchAgents/com.user.$SERVICE_NAME.plist"
    
    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.$SERVICE_NAME</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SYNC_DIR/auto-sync.sh</string>
        <string>-d</string>
        <string>$REPO_DIR</string>
        <string>-q</string>
$([ "$ENABLE_NOTIFY" = true ] && echo "        <string>-n</string>")
$([ "$ENABLE_ICLOUD" = true ] && echo "        <string>-i</string>")
    </array>
    
    <key>StartInterval</key>
    <integer>$((INTERVAL * 60))</integer>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>StandardOutPath</key>
    <string>$SYNC_DIR/sync-stdout.log</string>
    
    <key>StandardErrorPath</key>
    <string>$SYNC_DIR/sync-stderr.log</string>
</dict>
</plist>
EOF
    
    # Load the service
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    launchctl load "$PLIST_FILE"
    
    echo "✓ Installed launchd service: com.user.$SERVICE_NAME"
    echo "  Config: $PLIST_FILE"
    echo ""
    echo "Commands:"
    echo "  Status:  launchctl list | grep $SERVICE_NAME"
    echo "  Stop:    launchctl unload '$PLIST_FILE'"
    echo "  Start:   launchctl load '$PLIST_FILE'"
    echo "  Remove:  launchctl unload '$PLIST_FILE' && rm '$PLIST_FILE'"
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - prefer systemd, fallback to cron
    
    if command -v systemctl &> /dev/null && systemctl --user &> /dev/null; then
        # Use systemd
        echo "Setting up systemd timer..."
        
        SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE_NAME.service"
        TIMER_FILE="$HOME/.config/systemd/user/$SERVICE_NAME.timer"
        
        mkdir -p "$HOME/.config/systemd/user"
        
        # Create service file
        cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Auto-sync for $REPO_DIR
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash $SYNC_CMD
WorkingDirectory=$REPO_DIR

[Install]
WantedBy=default.target
EOF
        
        # Create timer file
        cat > "$TIMER_FILE" << EOF
[Unit]
Description=Auto-sync timer for $REPO_DIR
Requires=$SERVICE_NAME.service

[Timer]
OnCalendar=*:0/$INTERVAL
Persistent=true

[Install]
WantedBy=timers.target
EOF
        
        # Enable and start
        systemctl --user daemon-reload
        systemctl --user enable "$SERVICE_NAME.timer"
        systemctl --user start "$SERVICE_NAME.timer"
        
        echo "✓ Installed systemd timer: $SERVICE_NAME"
        echo ""
        echo "Commands:"
        echo "  Status:  systemctl --user status $SERVICE_NAME.timer"
        echo "  Stop:    systemctl --user stop $SERVICE_NAME.timer"
        echo "  Start:   systemctl --user start $SERVICE_NAME.timer"
        echo "  Remove:  systemctl --user disable $SERVICE_NAME.timer && rm '$SERVICE_FILE' '$TIMER_FILE'"
        
    else
        # Use cron
        echo "Setting up cron job..."
        
        # Add to crontab
        CRON_CMD="*/$INTERVAL * * * * $SYNC_CMD"
        
        # Check if already exists
        if crontab -l 2>/dev/null | grep -q "$REPO_DIR"; then
            echo "WARNING: Cron job already exists for $REPO_DIR"
        else
            (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
            echo "✓ Added cron job"
        fi
        
        echo ""
        echo "Commands:"
        echo "  List:    crontab -l"
        echo "  Edit:    crontab -e"
        echo "  Remove:  crontab -e  # then delete the line"
    fi
    
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows - use Task Scheduler
    echo "Setting up Windows Task Scheduler..."
    
    # Create a batch file to run the sync
    BAT_FILE="$SYNC_DIR/auto-sync.bat"
    cat > "$BAT_FILE" << EOF
@echo off
bash "$SYNC_DIR/auto-sync.sh" -d "$REPO_DIR" -q $([ "$ENABLE_NOTIFY" = true ] && echo "-n") $([ "$ENABLE_ICLOUD" = true ] && echo "-i")
EOF
    
    # Create scheduled task
    schtasks /create /tn "$SERVICE_NAME" \
        /tr "\"$BAT_FILE\"" \
        /sc minute /mo $INTERVAL \
        /f
    
    echo "✓ Created Windows scheduled task: $SERVICE_NAME"
    echo ""
    echo "Commands:"
    echo "  Status:  schtasks /query /tn '$SERVICE_NAME'"
    echo "  Stop:    schtasks /end /tn '$SERVICE_NAME'"
    echo "  Start:   schtasks /run /tn '$SERVICE_NAME'"
    echo "  Remove:  schtasks /delete /tn '$SERVICE_NAME' /f"
    
else
    echo "ERROR: Unsupported platform: $OSTYPE"
    exit 1
fi

echo ""
echo "✓ Auto-sync installed successfully!"
echo ""
echo "Repository: $REPO_DIR"
echo "Logs: $SYNC_DIR/sync.log"
echo ""
echo "Test the sync manually:"
echo "  $SYNC_DIR/auto-sync.sh -d '$REPO_DIR'"