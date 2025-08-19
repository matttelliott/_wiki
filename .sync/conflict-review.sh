#!/bin/bash

# conflict-review.sh - Review and resolve preserved conflicts

REPO_DIR="${1:-$(pwd)}"
cd "$REPO_DIR" || exit 1

echo "=== Conflict Review Tool ==="
echo ""

# Check for conflict branches
conflict_branches=$(git branch | grep "conflict-" | sed 's/^[ *]*//')

if [ -z "$conflict_branches" ]; then
    echo "✅ No conflicts to review!"
    exit 0
fi

echo "Found conflict branches:"
echo "$conflict_branches" | nl
echo ""

# Check for conflict records
if [ -d ".sync/conflicts" ]; then
    echo "Conflict details:"
    for file in .sync/conflicts/*.txt; do
        if [ -f "$file" ]; then
            echo "---"
            cat "$file"
        fi
    done
    echo ""
fi

echo "Options for each conflict branch:"
echo "  1. View the conflict"
echo "  2. Cherry-pick changes"
echo "  3. Merge the branch"
echo "  4. Delete (discard changes)"
echo ""

for branch in $conflict_branches; do
    echo "=== Branch: $branch ==="
    
    # Show what files were conflicted
    echo "Conflicted files:"
    git diff main..$branch --name-only
    echo ""
    
    echo -n "Action (1-4, s=skip): "
    read action
    
    case $action in
        1)
            echo "Showing changes in $branch:"
            git diff main..$branch
            echo -n "Press enter to continue..."
            read
            ;;
        2)
            echo "Cherry-picking from $branch..."
            git cherry-pick $branch
            if [ $? -eq 0 ]; then
                echo "✅ Cherry-pick successful"
                git branch -D $branch
                rm -f .sync/conflicts/$branch.txt
            else
                echo "❌ Cherry-pick failed - resolve manually"
            fi
            ;;
        3)
            echo "Merging $branch..."
            git merge $branch
            if [ $? -eq 0 ]; then
                echo "✅ Merge successful"
                git branch -D $branch
                rm -f .sync/conflicts/$branch.txt
            else
                echo "❌ Merge failed - resolve manually"
            fi
            ;;
        4)
            echo "Deleting $branch (discarding changes)..."
            git branch -D $branch
            rm -f .sync/conflicts/$branch.txt
            echo "✅ Branch deleted"
            ;;
        s|S)
            echo "Skipping $branch"
            ;;
        *)
            echo "Invalid option, skipping"
            ;;
    esac
    echo ""
done

# Clean up old conflict records
if [ -d ".sync/conflicts" ]; then
    # Remove records for non-existent branches
    for file in .sync/conflicts/*.txt; do
        if [ -f "$file" ]; then
            branch=$(basename "$file" .txt)
            if ! git branch | grep -q "$branch"; then
                rm "$file"
            fi
        fi
    done
fi

echo "=== Review Complete ==="

# Show remaining conflicts
remaining=$(git branch | grep "conflict-" | wc -l)
if [ $remaining -gt 0 ]; then
    echo "⚠️  $remaining conflict(s) still pending"
else
    echo "✅ All conflicts resolved!"
fi