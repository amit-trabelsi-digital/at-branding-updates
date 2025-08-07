#!/bin/bash

# Archive Legacy Branches Script
# This script renames branches to old-<branch> format and updates remote
# Excludes: main, dev-v1.1.0, test-v1.1.0, latest-base, temp-pre-cleanup-*

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "Archive Legacy Branches Script"
echo "Date: $(date)"
echo "========================================"
echo ""

# Create docs directory if it doesn't exist
mkdir -p docs

# Initialize the archived branches document
ARCHIVE_FILE="docs/archived-branches-20250806.md"
echo "# Archived Branches - $(date '+%Y-%m-%d %H:%M:%S')" > "$ARCHIVE_FILE"
echo "" >> "$ARCHIVE_FILE"
echo "The following branches were archived by adding 'old-' prefix:" >> "$ARCHIVE_FILE"
echo "" >> "$ARCHIVE_FILE"

# Patterns to exclude
EXCLUDE_PATTERNS=(
    "^main$"
    "^dev-v1.1.0$"
    "^test-v1.1.0$"
    "^latest-base$"
    "^temp-pre-cleanup-"
    "^old-"  # Don't rename already archived branches
)

# Function to check if branch should be excluded
should_exclude() {
    local branch=$1
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ $branch =~ $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# Counter for archived branches
ARCHIVED_COUNT=0
FAILED_COUNT=0

echo "Fetching latest branch information from remote..."
git fetch --all --prune

echo ""
echo "Processing local branches..."
echo "----------------------------"

# Get all local branches
LOCAL_BRANCHES=$(git branch --format='%(refname:short)' | grep -v '^*')

for branch in $LOCAL_BRANCHES; do
    if should_exclude "$branch"; then
        echo -e "${YELLOW}[SKIP]${NC} $branch - Protected branch"
        continue
    fi
    
    echo -e "${GREEN}[ARCHIVING]${NC} $branch -> old-$branch"
    
    # Archive the local branch
    if git branch -m "$branch" "old-$branch" 2>/dev/null; then
        echo "  ✓ Local branch renamed"
        
        # Delete the old remote branch and push the new one
        if git push origin :"$branch" 2>/dev/null; then
            echo "  ✓ Remote branch deleted"
        else
            echo -e "  ${YELLOW}⚠ Remote branch might not exist or already deleted${NC}"
        fi
        
        if git push -u origin "old-$branch" 2>/dev/null; then
            echo "  ✓ Archived branch pushed to remote"
            echo "- **$branch** → **old-$branch** (local + remote)" >> "$ARCHIVE_FILE"
            ((ARCHIVED_COUNT++))
        else
            echo -e "  ${RED}✗ Failed to push archived branch${NC}"
            ((FAILED_COUNT++))
        fi
    else
        echo -e "  ${RED}✗ Failed to rename local branch${NC}"
        ((FAILED_COUNT++))
    fi
    echo ""
done

echo "Processing remote-only branches..."
echo "-----------------------------------"

# Get all remote branches (excluding HEAD)
REMOTE_BRANCHES=$(git branch -r | grep -v 'HEAD' | sed 's/origin\///' | sort -u)

for branch in $REMOTE_BRANCHES; do
    # Skip if branch should be excluded
    if should_exclude "$branch"; then
        echo -e "${YELLOW}[SKIP]${NC} origin/$branch - Protected branch"
        continue
    fi
    
    # Check if we already have a local version (including old- prefixed)
    if git show-ref --verify --quiet "refs/heads/$branch" || git show-ref --verify --quiet "refs/heads/old-$branch"; then
        continue
    fi
    
    echo -e "${GREEN}[ARCHIVING]${NC} origin/$branch -> origin/old-$branch"
    
    # Create local tracking branch
    if git checkout -b "$branch" "origin/$branch" 2>/dev/null; then
        echo "  ✓ Created local tracking branch"
        
        # Rename local branch
        if git branch -m "$branch" "old-$branch" 2>/dev/null; then
            echo "  ✓ Local branch renamed"
            
            # Delete old remote branch
            if git push origin :"$branch" 2>/dev/null; then
                echo "  ✓ Remote branch deleted"
            else
                echo -e "  ${YELLOW}⚠ Could not delete remote branch${NC}"
            fi
            
            # Push renamed branch
            if git push -u origin "old-$branch" 2>/dev/null; then
                echo "  ✓ Archived branch pushed to remote"
                echo "- **$branch** → **old-$branch** (remote-only)" >> "$ARCHIVE_FILE"
                ((ARCHIVED_COUNT++))
            else
                echo -e "  ${RED}✗ Failed to push archived branch${NC}"
                ((FAILED_COUNT++))
            fi
        else
            echo -e "  ${RED}✗ Failed to rename branch${NC}"
            ((FAILED_COUNT++))
        fi
    else
        echo -e "  ${YELLOW}⚠ Branch might already be processed or doesn't exist${NC}"
    fi
    echo ""
done

# Return to main branch
echo "Returning to main branch..."
git checkout main 2>/dev/null || git checkout master 2>/dev/null

# Add summary to archive file
echo "" >> "$ARCHIVE_FILE"
echo "## Summary" >> "$ARCHIVE_FILE"
echo "" >> "$ARCHIVE_FILE"
echo "- Total branches archived: **$ARCHIVED_COUNT**" >> "$ARCHIVE_FILE"
echo "- Failed operations: **$FAILED_COUNT**" >> "$ARCHIVE_FILE"
echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$ARCHIVE_FILE"

# Display summary
echo ""
echo "========================================"
echo "Archive Complete!"
echo "========================================"
echo -e "${GREEN}✓ Archived branches: $ARCHIVED_COUNT${NC}"
if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "${RED}✗ Failed operations: $FAILED_COUNT${NC}"
fi
echo ""
echo "Archive report saved to: $ARCHIVE_FILE"
echo ""

# Show current branch status
echo "Current branch status:"
echo "----------------------"
git branch -a

exit 0
