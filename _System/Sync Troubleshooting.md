# Wiki Sync Troubleshooting Guide

## Quick Diagnostics

Run this first:
```bash
~/_wiki/.sync/sync-status.sh
```

## Common Issues and Solutions

### 1. iPhone Changes Lost During Sync

**Symptom**: Edits made on iPhone disappear after sync

**Cause**: Original sync script pulls before committing, causing iPhone changes to be stashed and lost

**Solution**: Use the improved sync script (`wiki-auto-sync-improved.sh`) which commits BEFORE pulling:
```bash
# Replace the old script
cp ~/.sync/wiki-auto-sync-improved.sh ~/.sync/wiki-auto-sync.sh
```

**Recovery**: Check git stash for lost changes:
```bash
git stash list
git stash show -p stash@{0}
```

### 2. Authentication Prompts During Auto-Commit

**Symptom**: 1Password prompts for authentication every 5 minutes

**Cause**: Git commit signing is enabled

**Solution**: Already fixed in sync script with `-c commit.gpgsign=false`

If still happening:
```bash
# Check if signing is enabled globally
git config --get commit.gpgsign

# Verify sync script has the fix
grep "commit.gpgsign=false" ~/.sync/wiki-auto-sync.sh
```

### 3. Constant Conflicts on sync.log Files

**Symptom**: Every sync causes merge conflicts in `.sync/sync.log`

**Cause**: Log files were being tracked in git, causing conflicts between machines

**Solution**: Log files are now excluded from git (only scripts are tracked):
```bash
# Already fixed in .gitignore:
.sync/*.log
.sync/.sync.lock
.sync/.conflict
```

**If still happening**: Remove log files from tracking:
```bash
git rm --cached .sync/*.log
git commit -m "Stop tracking log files"
```

### 4. "Failed to fetch from remote" Errors

**Symptom**: Repeated failures in sync log

**Possible Causes**:
- Network connectivity issue
- SSH key not loaded
- GitHub is down

**Solutions**:
```bash
# Test SSH connection
ssh -T git@github.com

# Check 1Password SSH agent
ssh-add -l

# Manually test fetch
cd ~/_wiki
git fetch origin main
```

### 3. "Push failed, attempting to sync" Loop

**Symptom**: Changes accumulate locally but don't push

**Cause**: Remote has changes not pulled locally

**Solution**:
```bash
cd ~/_wiki
git pull origin main
git push origin main
```

### 4. iCloud Repo Not Syncing

**Symptom**: iPhone changes don't appear in git

**Checks**:
```bash
# Verify iCloud repo exists and is separate
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Wiki
git status
git remote -v

# Check service is running
launchctl list | grep wiki-sync-icloud

# Check iCloud repo log
tail ~/.sync/sync.log | grep icloud
```

**Solution**:
```bash
# Restart iCloud sync service
launchctl unload ~/Library/LaunchAgents/com.user.wiki-sync-icloud.plist
launchctl load ~/Library/LaunchAgents/com.user.wiki-sync-icloud.plist
```

### 5. Google Drive Syncing .git Folder

**Symptom**: .git folder appears in Google Drive

**Solution**: Ensure `.gignore` file exists:
```bash
cat ~/_wiki/.gignore
# Should show: .git/
```

### 6. Merge Conflicts

**Symptom**: `.sync/.conflict` file exists

**Solution**:
```bash
# See what's conflicted
cat ~/_wiki/.sync/.conflict

# Resolve conflicts in files
git status
# Edit conflicted files

# Complete merge
git add .
git commit -m "Resolved conflicts"
rm ~/_wiki/.sync/.conflict
```

### 7. Services Not Starting on Boot

**macOS**:
```bash
# Check service status
launchctl list | grep wiki

# Reload services
launchctl unload ~/Library/LaunchAgents/com.user.wiki-sync.plist
launchctl load ~/Library/LaunchAgents/com.user.wiki-sync.plist
```

**Linux**:
```bash
# Check timer status
systemctl --user status wiki-sync.timer

# Enable and start
systemctl --user enable wiki-sync.timer
systemctl --user start wiki-sync.timer
```

### 8. Commits Not Happening

**Check if changes exist**:
```bash
cd ~/_wiki
git status
```

**Run manual sync**:
```bash
~/_wiki/.sync/wiki-auto-sync.sh
```

**Check for lock file**:
```bash
# Remove stale lock
rm ~/_wiki/.sync/.sync.lock
```

### 9. Wrong Platform Identifier in Commits

**Symptom**: Commits show wrong platform (e.g., "macos" for iCloud)

**Check environment**:
```bash
# For iCloud repo
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Wiki
WIKI_DIR="$PWD" bash -c 'echo $WIKI_DIR'
```

Platform detection relies on path containing "iCloud~md~obsidian"

### 10. Network Issues

**Symptoms**: Intermittent sync failures

**Solutions**:
- Sync automatically retries every 5 minutes
- Network issues self-resolve when connection returns
- Check GitHub status: https://www.githubstatus.com

## Log Analysis

### Understanding Sync Patterns

**Normal operation**:
```
[timestamp] [platform] Committed changes: Auto-sync from platform: timestamp
[timestamp] [platform] Pushed changes to remote
```

**Temporary network issue** (self-resolves):
```
[timestamp] [platform] Failed to fetch from remote
[timestamp] [platform] Committed changes: Auto-sync from platform: timestamp
[timestamp] [platform] Push failed, attempting to sync
# Later...
[timestamp] [platform] Pushed changes to remote
```

**Needs intervention**:
```
[timestamp] [platform] CONFLICT detected in files: [list]
```

## Manual Recovery Commands

### Full Reset (Nuclear Option)
```bash
# Backup current state
cp -r ~/_wiki ~/_wiki.backup

# Reset to remote state
cd ~/_wiki
git fetch origin
git reset --hard origin/main

# Restart services
launchctl unload ~/Library/LaunchAgents/com.user.wiki-sync*.plist
launchctl load ~/Library/LaunchAgents/com.user.wiki-sync*.plist
```

### Force Push Local State
```bash
cd ~/_wiki
git push --force origin main
# WARNING: This overwrites remote!
```

## Prevention Tips

1. **Don't manually edit in multiple locations simultaneously**
2. **Let auto-sync complete before switching devices**
3. **Check sync-status before major edits**
4. **Keep services running continuously**
5. **Don't modify .sync/ or .git/ directories**

## Getting Help

If issues persist:
1. Save output of `sync-status.sh`
2. Save last 50 lines of sync.log
3. Note exact error messages
4. Check `_System/Sync Architecture.md` for design details