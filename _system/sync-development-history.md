# Sync Development History

## Session: 2025-08-18 - Complete Sync System Build

### Starting Point
- Basic git setup with manual commits
- iPhone edits were getting lost
- Authentication prompts every 5 minutes
- No automatic syncing between local and iCloud

### Journey & Discoveries

#### Phase 1: Initial Sync Attempts
**Problem**: iPhone edits disappearing
- **Discovery**: Original script pulled BEFORE committing
- **Why it mattered**: Git stash was hiding uncommitted changes
- **Solution**: Always commit before pulling

**Test sequence**: 
- 7 iPhone updates tested
- First 2 lost, recovered from git stash
- Updates 3-7 successful after fix

#### Phase 2: iCloud Peculiarities
**Problem**: "Operation not permitted" errors in iCloud Drive
- **Discovery**: macOS blocks script execution in iCloud folders
- **Solution**: Run scripts from local location but operate on iCloud path

**Problem**: iPhone changes not appearing
- **Discovery**: iCloud requires files to be read to trigger downloads
- **Solution**: Added file reading step in sync script
```bash
find "$WIKI_DIR" -type f -name "*.md" -exec head -n 1 {} \; > /dev/null
```

#### Phase 3: Authentication Issues
**Problem**: 1Password prompting for authentication every sync
- **Discovery**: Git commit signing was enabled
- **Solution**: `-c commit.gpgsign=false` flag on all commits
- **Context**: User has 1Password managing SSH keys

#### Phase 4: True Bidirectional Sync
**Problem**: Changes from one location didn't appear in the other
- **Discovery**: Each location needs TWO sync cycles
- **Solution**: Created bidirectional-sync.sh
  - Phase 1: Both push their changes
  - Phase 2: Both pull each other's changes

#### Phase 5: Conflict Handling
**Problem**: Simultaneous edits cause sync to stop
- **Testing**: Created deliberate conflicts with different content
- **Observation**: Local usually "wins" (pushes first)
- **Solution**: Conflict Branch Strategy
  - Preserve conflicts in timestamped branches
  - Reset main to continue syncing
  - Review tool for later resolution

### Technical Decisions & Rationale

#### Why Separate Repos for Local and iCloud
- iCloud doesn't support symlinks
- Need separate git repos that sync to same GitHub remote
- Each maintains its own git history

#### Why Commit Before Pull
- Prevents loss of uncommitted changes
- Git stash was unreliable for recovery
- Ensures all changes are preserved in history

#### Why Branch Strategy for Conflicts
- Both versions preserved in git history
- Sync continues without manual intervention
- Can review conflicts when convenient
- Never lose data from either side

### Edge Cases Encountered

1. **Large sync delays**
   - Network issues caused fetch failures
   - System retries automatically every 5 minutes

2. **Merge conflicts on log files**
   - Excluded `.sync/*.log` from git tracking
   - Only track scripts, not logs

3. **Platform detection**
   - Used path matching for iCloud detection
   - `OSTYPE` for OS detection

4. **File name case conflicts**
   - `04-Daily` vs `04-daily` caused issues
   - Git case sensitivity varies by filesystem

### Scripts Evolution

```
Initial: 6 separate scripts
├── wiki-auto-sync.sh (original, flawed)
├── wiki-auto-sync-improved.sh 
├── wiki-auto-sync-icloud.sh
├── wiki-sync.sh
├── wiki-sync-all.sh
└── setup-sync.sh

Final: 4 core scripts
├── auto-sync.sh (generic, reusable)
├── bidirectional-sync.sh (orchestrator)
├── handle-conflicts.sh (branch preservation)
└── conflict-review.sh (resolution tool)
```

### Testing Log

| Test | Result | What We Learned |
|------|--------|-----------------|
| iPhone update 1 | Lost | Pull before commit loses changes |
| iPhone update 2 | Lost | Confirmed the pattern |
| iPhone update 3 | Success | Commit-first works |
| iPhone updates 4-7 | Success | Solution validated |
| Local→iCloud file | Success | Bidirectional working |
| iCloud→Local file | Success | Both directions confirmed |
| Simultaneous edit | Conflict | Local wins race condition |
| Conflict preservation | Success | Branch strategy works |

### Gotchas for Future

1. **Don't edit same file in both locations simultaneously**
   - Will create conflicts
   - System handles it but requires manual merge

2. **iCloud sync delays**
   - Sometimes takes 2-3 seconds for iCloud to download
   - Script waits but may need tuning

3. **Service naming**
   - launchd services need unique names
   - We used: com.user.wiki-bidirectional

4. **Path specifications**
   - Must use absolute paths in launchd plists
   - No ~ or $HOME in service files

### Performance Notes

- Sync runs every 5 minutes (300 seconds)
- Each sync takes ~5-10 seconds
- File reading for iCloud adds ~2 seconds
- Conflict creation/preservation adds ~3 seconds

### User Preferences Captured

- Minimal overhead preferred
- Wants "why" not "what" documentation
- Generic reusable solutions valued
- Never lose data (highest priority)
- Avoid manual intervention when possible

### What Works Well Now

✅ iPhone edits sync reliably
✅ No authentication prompts
✅ Conflicts don't break syncing
✅ Both versions preserved during conflicts
✅ System self-recovers from network issues
✅ Generic enough for other projects

### Known Limitations

- Conflicts require manual resolution (by design)
- 5-minute sync interval (configurable)
- Large binary files not tested
- Multiple simultaneous conflicts not extensively tested

### Future Improvements Discussed

- Automated conflict resolution for simple cases
- Notification system for conflicts
- Dashboard for sync health
- Performance optimization for large repos

### Recovery Procedures

If sync stops working:
```bash
# Check status
~/_wiki/.sync/sync-status.sh

# Check for conflicts
git branch | grep conflict-

# Review conflicts
~/_wiki/.sync/conflict-review.sh

# Restart service
launchctl unload ~/Library/LaunchAgents/com.user.wiki-bidirectional.plist
launchctl load ~/Library/LaunchAgents/com.user.wiki-bidirectional.plist
```

### Session Metrics

- Duration: ~3 hours
- Commits: ~40
- Tests run: ~15
- iPhone updates synced: 8
- Scripts created: 10
- Scripts kept: 4
- Problems solved: 5 major issues

### Key Insight

The most important lesson: **Always preserve data first, handle conflicts second**. This philosophy guided our branch strategy and ensures no work is ever lost, even if it requires manual review later.