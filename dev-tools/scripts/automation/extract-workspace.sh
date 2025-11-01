#!/usr/bin/env bash
# dev-tools/scripts/automation/extract-workspace.sh
#
# Extracts workspace context from ProspectPro to Dev-Tools repository
# Excludes transient session files and moves archives to legacy/

set -euo pipefail

PROSPECT_PRO_ROOT="${1:?Please provide ProspectPro repository path}"
DEV_TOOLS_ROOT="${2:?Please provide Dev-Tools repository path}"
DRY_RUN="${3:-false}"

RSYNC_OPTS="-av --progress"
if [ "$DRY_RUN" = "true" ]; then
  RSYNC_OPTS="$RSYNC_OPTS --dry-run"
  echo "=== DRY RUN MODE - No files will be copied ==="
fi

echo "=== Extracting Workspace Context ==="
echo "Source: $PROSPECT_PRO_ROOT"
echo "Target: $DEV_TOOLS_ROOT"
echo ""

# Create target directories
mkdir -p "$DEV_TOOLS_ROOT/workspace/context"
mkdir -p "$DEV_TOOLS_ROOT/legacy"

# Copy workspace context (excluding transient files)
echo "1. Copying workspace context..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/workspace/context" ]; then
  rsync $RSYNC_OPTS \
    --exclude="session_store/*.md" \
    --exclude="session_store/*.txt" \
    --exclude="session_store/*.log" \
    --exclude="session_store/diagnostics/*" \
    --exclude="archive/" \
    "$PROSPECT_PRO_ROOT/dev-tools/workspace/context/" \
    "$DEV_TOOLS_ROOT/workspace/context/"
else
  echo "  ⚠ Workspace context not found"
fi

# Move archives to legacy
echo ""
echo "2. Moving archives to legacy..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/workspace/context/archive" ]; then
  rsync $RSYNC_OPTS \
    "$PROSPECT_PRO_ROOT/dev-tools/workspace/context/archive/" \
    "$DEV_TOOLS_ROOT/legacy/context/"
else
  echo "  ⚠ Archive directory not found"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo ""
  echo "=== DRY RUN COMPLETE - No files were actually copied ==="
else
  echo ""
  echo "=== Workspace extraction complete ==="
  echo ""
  echo "Note: Transient session files excluded (*.md, *.txt, *.log in session_store)"
  echo "Note: Archives moved to legacy/ directory"
fi
