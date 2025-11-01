#!/usr/bin/env bash
# dev-tools/scripts/automation/extract-testing.sh
#
# Extracts testing infrastructure from ProspectPro to Dev-Tools repository

set -euo pipefail

PROSPECT_PRO_ROOT="${1:?Please provide ProspectPro repository path}"
DEV_TOOLS_ROOT="${2:?Please provide Dev-Tools repository path}"
DRY_RUN="${3:-false}"

RSYNC_OPTS="-av --progress"
if [ "$DRY_RUN" = "true" ]; then
  RSYNC_OPTS="$RSYNC_OPTS --dry-run"
  echo "=== DRY RUN MODE - No files will be copied ==="
fi

echo "=== Extracting Testing Infrastructure ==="
echo "Source: $PROSPECT_PRO_ROOT"
echo "Target: $DEV_TOOLS_ROOT"
echo ""

# Create target directories
mkdir -p "$DEV_TOOLS_ROOT/testing/configs"
mkdir -p "$DEV_TOOLS_ROOT/testing/agents"
mkdir -p "$DEV_TOOLS_ROOT/testing/utils"

# Copy test configurations
echo "1. Copying test configurations..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/testing/configs" ]; then
  rsync $RSYNC_OPTS \
    "$PROSPECT_PRO_ROOT/dev-tools/testing/configs/" \
    "$DEV_TOOLS_ROOT/testing/configs/"
else
  echo "  ⚠ Test configs not found"
fi

# Copy agent test suites
echo ""
echo "2. Copying agent test suites..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/testing/agents" ]; then
  rsync $RSYNC_OPTS \
    --exclude="node_modules" \
    --exclude="coverage" \
    --exclude="*.tsbuildinfo" \
    "$PROSPECT_PRO_ROOT/dev-tools/testing/agents/" \
    "$DEV_TOOLS_ROOT/testing/agents/"
else
  echo "  ⚠ Agent tests not found"
fi

# Copy test utilities
echo ""
echo "3. Copying test utilities..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/testing/utils" ]; then
  rsync $RSYNC_OPTS \
    "$PROSPECT_PRO_ROOT/dev-tools/testing/utils/" \
    "$DEV_TOOLS_ROOT/testing/utils/"
else
  echo "  ⚠ Test utilities not found"
fi

# Copy README if it exists
if [ -f "$PROSPECT_PRO_ROOT/dev-tools/testing/README.md" ]; then
  echo ""
  echo "4. Copying testing README..."
  cp "$PROSPECT_PRO_ROOT/dev-tools/testing/README.md" \
     "$DEV_TOOLS_ROOT/testing/"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo ""
  echo "=== DRY RUN COMPLETE - No files were actually copied ==="
else
  echo ""
  echo "=== Testing extraction complete ==="
fi
