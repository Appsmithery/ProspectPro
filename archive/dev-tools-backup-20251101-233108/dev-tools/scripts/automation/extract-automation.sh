#!/usr/bin/env bash
# dev-tools/scripts/automation/extract-automation.sh
#
# Extracts automation infrastructure from ProspectPro to Dev-Tools repository

set -euo pipefail

PROSPECT_PRO_ROOT="${1:?Please provide ProspectPro repository path}"
DEV_TOOLS_ROOT="${2:?Please provide Dev-Tools repository path}"
DRY_RUN="${3:-false}"

RSYNC_OPTS="-av --progress"
if [ "$DRY_RUN" = "true" ]; then
  RSYNC_OPTS="$RSYNC_OPTS --dry-run"
  echo "=== DRY RUN MODE - No files will be copied ==="
fi

echo "=== Extracting Automation Infrastructure ==="
echo "Source: $PROSPECT_PRO_ROOT"
echo "Target: $DEV_TOOLS_ROOT"
echo ""

# Create target directories
mkdir -p "$DEV_TOOLS_ROOT/automation/ci-cd"

# Copy CI/CD automation scripts
echo "1. Copying CI/CD scripts..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/automation/ci-cd" ]; then
  rsync $RSYNC_OPTS \
    --exclude="*.log" \
    "$PROSPECT_PRO_ROOT/dev-tools/automation/ci-cd/" \
    "$DEV_TOOLS_ROOT/automation/ci-cd/"
else
  echo "  ⚠ CI/CD scripts not found"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo ""
  echo "=== DRY RUN COMPLETE - No files were actually copied ==="
else
  echo ""
  echo "=== Automation extraction complete ==="
fi
