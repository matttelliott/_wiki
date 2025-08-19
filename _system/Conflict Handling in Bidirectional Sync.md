# Conflict Handling in Bidirectional Sync

## What Happens During Conflicts

When the same files are edited in both local and iCloud wikis:

### Current Behavior (from testing)

1. **Phase 1**: Both repos try to push their changes
   - The first repo to push "wins" and gets its version on GitHub
   - The second repo encounters a conflict when trying to push

2. **Phase 2**: Both repos try to pull
   - The repo that "won" stays clean
   - The repo that "lost" gets conflict markers in files

3. **Result**: 
   - One repo (usually local) ends up with the "winning" version
   - The other repo (usually iCloud) has unresolved conflicts with markers
   - Git prevents pushing until conflicts are resolved

### Conflict Markers Example
```
<<<<<<< HEAD
iCLOUD EDIT: Different edit to test conflict handling!
=======
LOCAL EDIT: Testing conflict resolution in bidirectional sync!
>>>>>>> 53dcddfd4f6097be992c1859249ccac01d20a3e7
```

## Limitations of Current System

1. **No automatic resolution** - Conflicts require manual intervention
2. **No notifications** - Unless you check logs, you won't know about conflicts
3. **Sync stops** - The repo with conflicts can't sync until resolved
4. **Race condition** - Whichever repo pushes first "wins"

## How to Handle Conflicts

### Check for Conflicts
```bash
# Check both repos
cd ~/_wiki && git status
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Wiki && git status

# Look for conflict markers
grep -r "<<<<<<< HEAD" ~/_wiki
grep -r "<<<<<<< HEAD" ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Wiki
```

### Resolve Conflicts

Option 1: Keep local version
```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Wiki
git checkout -- .  # Discard iCloud changes
```

Option 2: Keep iCloud version
```bash
cd ~/_wiki
git checkout -- .  # Discard local changes
```

Option 3: Manual merge
- Edit files to remove conflict markers
- Choose which parts to keep
- Stage and commit the resolution

## Recommendations

### To Minimize Conflicts

1. **Avoid simultaneous edits** - Don't edit the same files in both places
2. **Let sync complete** - Wait for sync before switching devices
3. **Use one primary location** - Prefer local for Mac work, iCloud for iPhone

### Potential Improvements

1. **Add conflict detection** to bidirectional-sync.sh
2. **Send notifications** when conflicts occur
3. **Auto-resolve strategy** options:
   - Always prefer local
   - Always prefer iCloud
   - Prefer most recent
   - Merge both versions
4. **Conflict flag file** to track unresolved conflicts

## Current Sync Priority

Based on testing, the sync system tends to favor the **local wiki** version when conflicts occur, likely because it syncs slightly faster in Phase 1 of the bidirectional sync.