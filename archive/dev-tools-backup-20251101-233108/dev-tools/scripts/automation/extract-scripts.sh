#!/usr/bin/env bash
# dev-tools/scripts/automation/extract-scripts.sh
#
# Extracts portable scripts from ProspectPro to Dev-Tools repository
# Excludes app-specific scripts (Highlight integration, Vercel validation)

set -euo pipefail

PROSPECT_PRO_ROOT="${1:?Please provide ProspectPro repository path}"
DEV_TOOLS_ROOT="${2:?Please provide Dev-Tools repository path}"
DRY_RUN="${3:-false}"

RSYNC_OPTS="-av --progress"
if [ "$DRY_RUN" = "true" ]; then
  RSYNC_OPTS="$RSYNC_OPTS --dry-run"
  echo "=== DRY RUN MODE - No files will be copied ==="
fi

echo "=== Extracting Portable Scripts ==="
echo "Source: $PROSPECT_PRO_ROOT"
echo "Target: $DEV_TOOLS_ROOT"
echo ""

# Create target directories
mkdir -p "$DEV_TOOLS_ROOT/scripts/automation"
mkdir -p "$DEV_TOOLS_ROOT/scripts/setup"
mkdir -p "$DEV_TOOLS_ROOT/scripts/tooling"

# Copy automation scripts (excluding app-specific ones)
echo "1. Copying automation scripts (excluding app-specific)..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/scripts/automation" ]; then
  rsync $RSYNC_OPTS \
    --exclude="integrate-highlight-edge-functions.ts" \
    --exclude="vercel-validate.sh" \
    --exclude="deploy-highlight-integration.sh" \
    --exclude="highlight-integration-inventory.sh" \
    "$PROSPECT_PRO_ROOT/dev-tools/scripts/automation/" \
    "$DEV_TOOLS_ROOT/scripts/automation/"
else
  echo "  ⚠ Automation scripts not found"
fi

# Copy setup scripts
echo ""
echo "2. Copying setup scripts..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/scripts/setup" ]; then
  rsync $RSYNC_OPTS \
    "$PROSPECT_PRO_ROOT/dev-tools/scripts/setup/" \
    "$DEV_TOOLS_ROOT/scripts/setup/"
else
  echo "  ⚠ Setup scripts not found"
fi

# Copy tooling scripts
echo ""
echo "3. Copying tooling scripts..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/scripts/tooling" ]; then
  rsync $RSYNC_OPTS \
    "$PROSPECT_PRO_ROOT/dev-tools/scripts/tooling/" \
    "$DEV_TOOLS_ROOT/scripts/tooling/"
else
  echo "  ⚠ Tooling scripts not found"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo ""
  echo "=== DRY RUN COMPLETE - No files were actually copied ==="
else
  echo ""
  echo "=== Scripts extraction complete ==="
  echo ""
  echo "App-specific scripts excluded (remain in ProspectPro):"
  echo "  - integrate-highlight-edge-functions.ts"
  echo "  - vercel-validate.sh"
  echo "  - deploy-highlight-integration.sh"
  echo "  - highlight-integration-inventory.sh"
fi
