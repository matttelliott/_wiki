# Generic Auto-Sync Guide

## Overview
A reusable git auto-sync system that can be used for any repository: dotfiles, notes, wikis, or any frequently-changing files.

## Quick Start

### For Dotfiles
```bash
cd ~/dotfiles
curl -sSL https://raw.githubusercontent.com/matttelliott/_wiki/main/.sync/install-auto-sync.sh | bash -s -- --name dotfiles --interval 10
```

### For Notes
```bash
cd ~/notes
./install-auto-sync.sh --notify --interval 5
```

### For iCloud Synced Folders
```bash
cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/MyProject
./install-auto-sync.sh --icloud --interval 5
```

## Features

- **Commits before pulling** - Never lose local changes
- **Automatic conflict handling** - Tries rebase, then merge
- **Platform detection** - Works on macOS, Linux, Windows
- **Optional notifications** - Get alerted to conflicts
- **iCloud support** - Handles Apple's cloud sync quirks
- **Customizable** - Commit messages, intervals, logging

## Scripts

### `auto-sync.sh` - The Core Script
The reusable sync engine that handles all git operations.

**Key Options:**
- `-d, --dir PATH` - Repository directory
- `-m, --message` - Custom commit prefix (default: "Auto-sync")
- `-n, --notify` - Enable desktop notifications
- `-i, --icloud` - Enable iCloud file reading
- `-q, --quiet` - Suppress output (for cron/launchd)

**Examples:**
```bash
# Simple sync
./auto-sync.sh

# Sync specific directory with notifications
./auto-sync.sh -d ~/projects/myrepo -n

# Custom commit message
./auto-sync.sh -m "Config backup"

# iCloud repository
./auto-sync.sh -d ~/Library/Mobile\ Documents/... -i
```

### `install-auto-sync.sh` - The Installer
Sets up automatic syncing based on your platform:
- **macOS**: Creates launchd service
- **Linux**: Creates systemd timer (or cron job)
- **Windows**: Creates Task Scheduler task

**Examples:**
```bash
# Install with defaults (5 minute interval)
./install-auto-sync.sh

# Custom interval and notifications
./install-auto-sync.sh --interval 10 --notify

# Named service
./install-auto-sync.sh --name my-dotfiles --interval 15
```

## Use Cases

### 1. Dotfiles Syncing
Keep your dotfiles synchronized across machines:

```bash
cd ~/dotfiles
git init
git remote add origin git@github.com:yourusername/dotfiles.git

# Install auto-sync
./install-auto-sync.sh --name dotfiles --interval 10

# Your dotfiles now sync every 10 minutes!
```

### 2. Obsidian Notes (without iCloud)
Sync your Obsidian vault using git:

```bash
cd ~/Documents/ObsidianVault
git init
git remote add origin git@github.com:yourusername/notes.git

# Install with notifications
./install-auto-sync.sh --name obsidian --notify --interval 5
```

### 3. Project Documentation
Keep project docs in sync:

```bash
cd ~/projects/my-app/docs
./install-auto-sync.sh --name my-app-docs --message "Doc update"
```

### 4. Configuration Backups
Backup application configs:

```bash
cd ~/.config
git init
git remote add origin git@github.com:yourusername/configs.git
./install-auto-sync.sh --name configs --interval 30
```

## Managing Services

### macOS (launchd)
```bash
# Check status
launchctl list | grep auto-sync

# Stop service
launchctl unload ~/Library/LaunchAgents/com.user.auto-sync-*.plist

# Start service
launchctl load ~/Library/LaunchAgents/com.user.auto-sync-*.plist

# View logs
tail -f ~/.sync/sync.log
```

### Linux (systemd)
```bash
# Check status
systemctl --user status auto-sync-*.timer

# Stop service
systemctl --user stop auto-sync-*.timer

# Start service
systemctl --user start auto-sync-*.timer

# View logs
journalctl --user -u auto-sync-*.service -f
```

### Linux (cron)
```bash
# List jobs
crontab -l

# Edit jobs
crontab -e

# View logs
tail -f ~/.sync/sync.log
```

## Advanced Configuration

### Custom Sync Logic
Create a wrapper script for complex scenarios:

```bash
#!/bin/bash
# my-custom-sync.sh

# Pre-sync tasks
echo "Running pre-sync..."

# Call auto-sync with your options
/path/to/auto-sync.sh -d ~/myrepo -m "Custom sync" -n

# Post-sync tasks
echo "Running post-sync..."
```

### Multiple Repositories
Sync multiple repos with one service:

```bash
#!/bin/bash
# sync-all.sh

repos=(
    "$HOME/dotfiles"
    "$HOME/notes"
    "$HOME/projects/docs"
)

for repo in "${repos[@]}"; do
    /path/to/auto-sync.sh -d "$repo" -q
done
```

### Exclude Files
Use `.gitignore` to exclude files from syncing:

```gitignore
# .gitignore
*.log
*.tmp
.DS_Store
node_modules/
.env
secrets/
```

## Troubleshooting

### Conflicts
When conflicts occur:
1. A notification appears (if enabled)
2. `.sync/.conflict` file is created
3. Manually resolve conflicts
4. The next sync will clear the conflict flag

### Authentication Issues
For password-less operation:
- Use SSH keys with git
- Disable commit signing for auto-commits
- Use SSH agent or credential manager

### iCloud Issues
If iCloud files aren't syncing:
- Enable `--icloud` flag
- Script will read files to trigger downloads
- Wait a few seconds for iCloud to sync

### Permission Errors
```bash
# Fix permissions
chmod +x auto-sync.sh
chmod 755 .sync/
```

## Uninstalling

### macOS
```bash
SERVICE_NAME="auto-sync-myrepo"
launchctl unload ~/Library/LaunchAgents/com.user.$SERVICE_NAME.plist
rm ~/Library/LaunchAgents/com.user.$SERVICE_NAME.plist
rm -rf .sync/
```

### Linux (systemd)
```bash
SERVICE_NAME="auto-sync-myrepo"
systemctl --user stop $SERVICE_NAME.timer
systemctl --user disable $SERVICE_NAME.timer
rm ~/.config/systemd/user/$SERVICE_NAME.*
rm -rf .sync/
```

### Linux (cron)
```bash
crontab -e  # Remove the line
rm -rf .sync/
```

## Why Use This?

- **Never lose work** - Commits before pulling
- **Works everywhere** - Cross-platform support
- **Set and forget** - Runs automatically
- **Conflict-aware** - Notifies when manual intervention needed
- **Reusable** - One script for all your repos
- **Lightweight** - Just bash and git

## Contributing

The scripts are open source. Feel free to:
- Report issues
- Suggest improvements
- Add platform support
- Share your use cases

## License

MIT - Use freely for any purpose