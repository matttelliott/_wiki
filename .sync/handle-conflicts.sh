#!/bin/bash

# handle-conflicts.sh - Handle git conflicts by preserving in branches

REPO_DIR="${1:-$(pwd)}"
cd "$REPO_DIR" || exit 1

# Check for conflicts
conflicted_files=$(git diff --name-only --diff-filter=U 2>/dev/null)

if [ -n "$conflicted_files" ]; then
    echo "Handling conflicts in: $conflicted_files"
    
    # Create unique branch name
    conflict_branch="conflict-$(date +%Y%m%d-%H%M%S)"
    
    # Add all files including those with conflict markers
    git add -A
    
    # Commit the conflicted state
    git -c commit.gpgsign=false commit -m "CONFLICT: Preserving both versions" --no-verify 2>/dev/null || {
        echo "Could not commit conflicts"
        exit 1
    }
    
    # Create branch to preserve this state
    git branch "$conflict_branch"
    echo "Created branch: $conflict_branch"
    
    # Track the conflict
    mkdir -p "$REPO_DIR/.sync/conflicts"
    cat > "$REPO_DIR/.sync/conflicts/$conflict_branch.txt" << EOF
Date: $(date)
Branch: $conflict_branch
Repository: $REPO_DIR
Files: $conflicted_files
Status: pending
EOF
    
    # Reset to remote to continue syncing
    branch=$(git symbolic-ref --short HEAD)
    git reset --hard origin/$branch
    echo "Reset to origin/$branch to continue syncing"
    
    echo "✅ Conflicts preserved in branch: $conflict_branch"
    echo "   Run 'conflict-review.sh' to resolve later"
    
    exit 0
else
    echo "No conflicts found"
    exit 1
fi