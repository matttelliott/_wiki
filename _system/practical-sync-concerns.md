# Practical Sync Concerns (Single User)

## Real Issues to Watch

### 1. Accumulating Conflict Branches
**The Problem**: Conflict branches build up over time if you forget about them
**Why it matters**: Git repo gets cluttered, hard to find real branches

**Quick Check**:
```bash
# Add to your .zshrc or .bashrc for easy checking
alias wiki-conflicts='cd ~/_wiki && git branch | grep conflict- | wc -l'
```

**Notification Ideas** (for future implementation):
- macOS Notification Center alert when >3 conflict branches
- Add to your shell prompt when conflicts exist
- Daily reminder via Shortcuts app
- Obsidian plugin to show conflict count

### 2. Large Media Files
**Current Reality**: Git will handle them but slowly
**Practical limits**: 
- Images under 10MB - no problem
- Videos under 50MB - slow but works
- Anything larger - consider external hosting

**For now**: Just be mindful of file sizes
**Long term**: Consider:
- Git LFS for media files
- Separate media sync via iCloud only (no git)
- Image optimization on commit
- External CDN for videos

### 3. Actually Likely Scenarios

#### Forgetting Phone in Airplane Mode
- Edit on phone
- Forget it's in airplane mode
- Edit same files on Mac
- Turn off airplane mode → conflict

**Mitigation**: Just check for conflicts after travel

#### Obsidian Cache/Workspace Files
- These change constantly
- Already in .gitignore
- But sometimes Obsidian creates new cache files

**Watch for**: Random .obsidian files being committed

#### Accidental Large File Commits
**Prevention script** (add to auto-sync):
```bash
# Warn about large files
large_files=$(find . -type f -size +10M -not -path "./.git/*" 2>/dev/null)
if [ -n "$large_files" ]; then
    echo "Warning: Large files detected:"
    echo "$large_files"
fi
```

## What's Actually Working Well

- ✅ Network interruptions - Git handles gracefully
- ✅ GitHub downtime - Just retries later
- ✅ Sync timing - 5 minutes is perfect balance
- ✅ Authentication - Solved with commit.gpgsign=false
- ✅ iPhone sync - File reading trick works great

## Simple Monitoring

Instead of complex monitoring, just add this to your daily routine:

```bash
# Add to .zshrc for daily check
wiki-check() {
    echo "=== Wiki Health ==="
    cd ~/_wiki
    
    # Check for conflicts
    conflicts=$(git branch | grep conflict- | wc -l)
    if [ $conflicts -gt 0 ]; then
        echo "⚠️  You have $conflicts conflict branches to review"
        echo "   Run: ~/_wiki/.sync/conflict-review.sh"
    else
        echo "✅ No conflicts"
    fi
    
    # Check last sync
    last_sync=$(tail -1 .sync/sync.log 2>/dev/null | cut -d' ' -f2)
    echo "📝 Last sync: $last_sync"
    
    # Check for large files
    large=$(find . -type f -size +10M -not -path "./.git/*" 2>/dev/null | wc -l)
    if [ $large -gt 0 ]; then
        echo "📦 Large files: $large files over 10MB"
    fi
}
```

## Future Improvements Priority

### High Priority (Actually Needed)
1. **Conflict branch notifications** - Simple macOS notification when conflicts exist
2. **Large file handling** - Warn before committing files >10MB

### Nice to Have
3. Media optimization pipeline
4. Conflict auto-resolution for simple cases
5. Obsidian integration for sync status

### Probably Overkill
- Complex monitoring dashboards
- Automated recovery systems
- Multi-user conflict resolution
- Real-time sync (5 minutes is fine)

## The Bottom Line

The system is working well for single-user use. The only real concern is remembering to check for conflict branches occasionally. Everything else is either handled automatically or unlikely to occur.

**Daily habit**: Just run `wiki-check` each morning. That's it.