#!/bin/bash

# Minimal test to demonstrate iCloud access problem from launchd

ICLOUD_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Wiki"
LOG_FILE="/tmp/icloud-test.log"

echo "=== iCloud Access Test ===" > "$LOG_FILE"
echo "Time: $(date)" >> "$LOG_FILE"
echo "Running as: $(whoami)" >> "$LOG_FILE"
echo "PWD: $(pwd)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "Test 1: Can we list iCloud directory?" >> "$LOG_FILE"
ls "$ICLOUD_PATH" > /dev/null 2>&1
echo "Result: $?" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "Test 2: Can we use git -C to fetch?" >> "$LOG_FILE"
git -C "$ICLOUD_PATH" fetch origin main 2>&1 | head -5 >> "$LOG_FILE"
echo "Result: $?" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "Test 3: Can we read a file?" >> "$LOG_FILE"
head -1 "$ICLOUD_PATH/.git/config" 2>&1 >> "$LOG_FILE"
echo "Result: $?" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "Test 4: What about GIT_DIR approach?" >> "$LOG_FILE"
GIT_DIR="$ICLOUD_PATH/.git" git fetch origin main 2>&1 | head -5 >> "$LOG_FILE"
echo "Result: $?" >> "$LOG_FILE"

echo "=== End Test ===" >> "$LOG_FILE"