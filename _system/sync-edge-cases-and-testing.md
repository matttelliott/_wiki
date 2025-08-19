# Sync Edge Cases and Testing Guide

## Most Likely Edge Cases

### 1. Race Condition: Simultaneous Edits
**Scenario**: Editing same file on Mac and iPhone within 5-minute window
**Current behavior**: Creates conflict branches
**Test**: 
```bash
# Create simultaneous edits
echo "Mac edit $(date)" >> test-file.md
# Immediately on iPhone: edit same file
# Wait for sync cycle
git branch | grep conflict-  # Should show conflict branch
```
**Prevention**: 
- Shorter sync intervals (but increases overhead)
- File locking mechanism (complex)
- Best practice: Avoid simultaneous edits

### 2. Large File Sync
**Scenario**: Adding large images, PDFs, or videos
**Risk**: Timeout during sync, incomplete pushes
**Test**:
```bash
# Create large test file
dd if=/dev/zero of=test-large.bin bs=1m count=50
# Wait for sync
# Check both repos have complete file
```
**Prevention**:
- Add timeout handling in scripts
- Consider git-lfs for large files
- Add file size warnings

### 3. Network Interruption Mid-Sync
**Scenario**: WiFi drops during push/pull
**Current behavior**: Fails silently, retries next cycle
**Test**:
```bash
# Start sync then disconnect network
sudo ifconfig en0 down
# Wait, reconnect
sudo ifconfig en0 up
# Check sync recovers
```
**Prevention**: Already handles via 5-minute retry

### 4. GitHub Down/Unreachable
**Scenario**: GitHub has outage or rate limits hit
**Current behavior**: Logs "Failed to fetch"
**Test**:
```bash
# Temporarily block GitHub
sudo echo "127.0.0.1 github.com" >> /etc/hosts
# Wait for sync attempts
# Check logs for graceful failure
sudo sed -i '' '/github.com/d' /etc/hosts
```

### 5. Corrupt Git State
**Scenario**: Git index corrupted, HEAD detached
**Risk**: Sync stops completely
**Test**:
```bash
# Corrupt index (careful!)
echo "corrupt" > .git/index
# See if sync detects and recovers
```
**Prevention**: Add git fsck check before sync

### 6. Storage Full
**Scenario**: Disk space exhausted
**Risk**: Partial commits, corrupted repo
**Test**:
```bash
# Fill disk (carefully!)
dd if=/dev/zero of=/tmp/bigfile bs=1g count=999
# Try to sync
# Check handling
rm /tmp/bigfile
```

### 7. Multiple Conflict Branches Accumulating
**Scenario**: Never resolving conflicts, branches pile up
**Current behavior**: Branches accumulate indefinitely
**Test**:
```bash
# Create 10 conflicts
for i in {1..10}; do
    echo "conflict $i" > test-$i.md
    # Edit same file in other repo
done
# Check branch list grows
git branch | grep conflict- | wc -l
```
**Prevention**: 
- Add warning when >5 conflict branches
- Auto-cleanup old branches (>30 days)

### 8. Case Sensitivity Issues
**Scenario**: File.md vs file.md on case-insensitive filesystem
**Risk**: Overwrites, lost data
**Test**:
```bash
echo "test" > Test-Case.md
echo "different" > test-case.md
# See what happens
```

### 9. Symlink Handling
**Scenario**: Adding symlinks to wiki
**Risk**: iCloud doesn't support, could break sync
**Test**:
```bash
ln -s /etc/hosts test-symlink
# Wait for sync
# Check both repos
```

### 10. Binary File Conflicts
**Scenario**: Images edited in both locations
**Current behavior**: Can't merge binaries
**Test**:
```bash
# Add image to both repos with different content
# Check conflict handling
```

## Monitoring Script

Create this monitoring script to detect issues:

```bash
#!/bin/bash
# sync-health-check.sh

WARNINGS=0

# Check for old unsynced commits
UNPUSHED=$(git log origin/main..HEAD --oneline | wc -l)
if [ $UNPUSHED -gt 5 ]; then
    echo "⚠️  WARNING: $UNPUSHED unpushed commits"
    WARNINGS=$((WARNINGS + 1))
fi

# Check for accumulating conflict branches
CONFLICTS=$(git branch | grep conflict- | wc -l)
if [ $CONFLICTS -gt 5 ]; then
    echo "⚠️  WARNING: $CONFLICTS unresolved conflict branches"
    WARNINGS=$((WARNINGS + 1))
fi

# Check last sync time
LAST_SYNC=$(tail -1 ~/.sync/sync.log | cut -d' ' -f2)
LAST_EPOCH=$(date -j -f "%H:%M:%S" "$LAST_SYNC" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)
DIFF=$((NOW_EPOCH - LAST_EPOCH))
if [ $DIFF -gt 600 ]; then  # 10 minutes
    echo "⚠️  WARNING: No sync for $((DIFF/60)) minutes"
    WARNINGS=$((WARNINGS + 1))
fi

# Check for git index lock
if [ -f .git/index.lock ]; then
    echo "⚠️  WARNING: Git index locked"
    WARNINGS=$((WARNINGS + 1))
fi

# Check disk space
DISK_USAGE=$(df . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    echo "⚠️  WARNING: Disk ${DISK_USAGE}% full"
    WARNINGS=$((WARNINGS + 1))
fi

# Check for merge conflicts in files
if grep -r "<<<<<<< HEAD" . --exclude-dir=.git 2>/dev/null; then
    echo "⚠️  WARNING: Unresolved merge conflicts in files"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $WARNINGS -eq 0 ]; then
    echo "✅ Sync health check passed"
else
    echo "❌ Sync health check: $WARNINGS warnings"
fi

exit $WARNINGS
```

## Stress Test Suite

```bash
#!/bin/bash
# sync-stress-test.sh

echo "Starting sync stress tests..."

# Test 1: Rapid changes
echo "Test 1: Rapid changes"
for i in {1..10}; do
    echo "Change $i at $(date)" >> stress-test.md
    sleep 1
done

# Test 2: Large file
echo "Test 2: Large file"
dd if=/dev/urandom of=large-test.bin bs=1m count=10 2>/dev/null

# Test 3: Many small files
echo "Test 3: Many files"
for i in {1..50}; do
    echo "File $i" > test-many-$i.md
done

# Test 4: Deep directory structure
echo "Test 4: Deep directories"
mkdir -p deep/nested/structure/test/folder
echo "deep file" > deep/nested/structure/test/folder/file.md

# Test 5: Special characters in filenames
echo "Test 5: Special characters"
touch "test file with spaces.md"
touch "test-file-with-émojis-🎉.md"
touch "test#file%with&symbols.md"

echo "Waiting for sync cycle..."
sleep 310  # Wait for full sync cycle

# Check results
echo "Checking results..."
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Wiki
if [ -f "stress-test.md" ] && [ -f "large-test.bin" ]; then
    echo "✅ Files synced to iCloud"
else
    echo "❌ Some files missing in iCloud"
fi

# Cleanup
echo "Cleaning up test files..."
rm -f stress-test.md large-test.bin test-many-*.md
rm -rf deep/
rm -f "test file with spaces.md" "test-file-with-émojis-🎉.md" "test#file%with&symbols.md"
```

## Prevention Strategies

### 1. Pre-sync Validation
Add to bidirectional-sync.sh:
```bash
# Check git state before sync
if ! git status &>/dev/null; then
    echo "Git state corrupted, attempting repair..."
    git fsck --full
fi

# Check disk space
if [ $(df . | awk 'NR==2 {print $5}' | sed 's/%//') -gt 95 ]; then
    echo "Disk nearly full, skipping sync"
    exit 1
fi
```

### 2. Conflict Branch Cleanup
Add weekly cleanup:
```bash
# Clean old conflict branches (>30 days)
for branch in $(git branch | grep conflict-); do
    AGE=$(git log -1 --format=%ct $branch)
    NOW=$(date +%s)
    DAYS=$(( (NOW - AGE) / 86400 ))
    if [ $DAYS -gt 30 ]; then
        git branch -D $branch
        echo "Deleted old conflict branch: $branch"
    fi
done
```

### 3. Network Resilience
Enhance retry logic:
```bash
# Exponential backoff for network issues
RETRY=0
MAX_RETRY=3
while [ $RETRY -lt $MAX_RETRY ]; do
    if git fetch origin main 2>/dev/null; then
        break
    fi
    WAIT=$((2 ** RETRY * 5))
    echo "Network issue, retry in ${WAIT}s..."
    sleep $WAIT
    RETRY=$((RETRY + 1))
done
```

### 4. Add Circuit Breaker
Stop trying if too many failures:
```bash
# Track consecutive failures
FAIL_COUNT_FILE=".sync/fail-count"
if [ -f "$FAIL_COUNT_FILE" ]; then
    FAILS=$(cat "$FAIL_COUNT_FILE")
else
    FAILS=0
fi

if [ $FAILS -gt 10 ]; then
    echo "Too many failures, circuit breaker triggered"
    send_notification "Sync Stopped" "Manual intervention needed"
    exit 1
fi
```

## Regular Maintenance Tasks

### Daily
- Check for conflict branches: `git branch | grep conflict-`
- Review sync log for errors: `grep -i error ~/.sync/sync.log`

### Weekly  
- Run health check script
- Clean old conflict branches
- Check disk usage

### Monthly
- Run full stress test suite
- Review and optimize sync intervals
- Update documentation with new edge cases found

## Quick Diagnostic Commands

```bash
# Check sync is running
launchctl list | grep wiki-bidirectional

# Check for stuck locks
ls -la ~/.sync/.sync.lock

# Check git state
git status
git fsck

# Check recent sync activity
tail -20 ~/.sync/sync.log

# Check for conflicts
git branch | grep conflict-
grep -r "<<<<<<< HEAD" . --exclude-dir=.git

# Check both repos in sync
cd ~/_wiki && git log --oneline -1
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Wiki && git log --oneline -1
```

## When Things Go Wrong

1. **First**: Run `sync-status.sh`
2. **Check logs**: `tail -50 ~/.sync/sync.log`
3. **Check git state**: `git status` in both repos
4. **Check services**: `launchctl list | grep wiki`
5. **Nuclear option**: Reset to remote
   ```bash
   git fetch origin
   git reset --hard origin/main
   ```

Remember: The system is designed to preserve data above all else. Even in worst case, check conflict branches and git reflog for recovery.