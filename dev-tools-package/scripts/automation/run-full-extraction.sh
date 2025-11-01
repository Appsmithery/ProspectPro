#!/usr/bin/env bash
# dev-tools/scripts/automation/run-full-extraction.sh
#
# Master script to orchestrate full dev-tools extraction from ProspectPro
# Runs all extraction scripts in the correct sequence with validation

set -euo pipefail

PROSPECT_PRO_ROOT="${1:?Please provide ProspectPro repository path}"
DEV_TOOLS_ROOT="${2:?Please provide Dev-Tools repository path}"
DRY_RUN="${3:-false}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$DRY_RUN" = "true" ]; then
  echo "========================================="
  echo "    DRY RUN MODE - NO FILES COPIED"
  echo "========================================="
  echo ""
fi

echo "=== Full Dev-Tools Extraction Orchestration ==="
echo "Source: $PROSPECT_PRO_ROOT"
echo "Target: $DEV_TOOLS_ROOT"
echo ""

# Validate source repository
if [ ! -d "$PROSPECT_PRO_ROOT/dev-tools" ]; then
  echo "❌ Source repository not found or invalid: $PROSPECT_PRO_ROOT"
  exit 1
fi

# Validate or create target repository
if [ ! -d "$DEV_TOOLS_ROOT" ]; then
  echo "⚠ Target directory does not exist: $DEV_TOOLS_ROOT"
  if [ "$DRY_RUN" = "false" ]; then
    read -p "Create target directory? (yes/no): " create
    if [ "$create" != "yes" ]; then
      echo "Extraction cancelled"
      exit 1
    fi
    mkdir -p "$DEV_TOOLS_ROOT"
  fi
fi

# Phase 1: Extract Agents
echo ""
echo "========================================"
echo "Phase 1: Extracting Agents Domain"
echo "========================================"
bash "$SCRIPT_DIR/extract-agents.sh" "$PROSPECT_PRO_ROOT" "$DEV_TOOLS_ROOT" "$DRY_RUN"

# Phase 2: Extract Automation
echo ""
echo "========================================"
echo "Phase 2: Extracting Automation Domain"
echo "========================================"
bash "$SCRIPT_DIR/extract-automation.sh" "$PROSPECT_PRO_ROOT" "$DEV_TOOLS_ROOT" "$DRY_RUN"

# Phase 3: Extract Scripts
echo ""
echo "========================================"
echo "Phase 3: Extracting Scripts Domain"
echo "========================================"
bash "$SCRIPT_DIR/extract-scripts.sh" "$PROSPECT_PRO_ROOT" "$DEV_TOOLS_ROOT" "$DRY_RUN"

# Phase 4: Extract Testing
echo ""
echo "========================================"
echo "Phase 4: Extracting Testing Domain"
echo "========================================"
bash "$SCRIPT_DIR/extract-testing.sh" "$PROSPECT_PRO_ROOT" "$DEV_TOOLS_ROOT" "$DRY_RUN"

# Phase 5: Extract Workspace
echo ""
echo "========================================"
echo "Phase 5: Extracting Workspace Domain"
echo "========================================"
bash "$SCRIPT_DIR/extract-workspace.sh" "$PROSPECT_PRO_ROOT" "$DEV_TOOLS_ROOT" "$DRY_RUN"

# Summary
echo ""
echo "========================================"
echo "   Extraction Complete"
echo "========================================"
echo ""

if [ "$DRY_RUN" = "true" ]; then
  echo "DRY RUN SUMMARY:"
  echo "- All extraction scripts executed successfully"
  echo "- No files were actually copied"
  echo "- Review output above for what would be extracted"
  echo ""
  echo "To perform actual extraction, run:"
  echo "  $0 $PROSPECT_PRO_ROOT $DEV_TOOLS_ROOT false"
else
  echo "EXTRACTION SUMMARY:"
  echo "- All domains extracted successfully"
  echo "- Target: $DEV_TOOLS_ROOT"
  echo ""
  echo "Next steps:"
  echo "1. cd $DEV_TOOLS_ROOT"
  echo "2. Review extracted files"
  echo "3. Run validation scripts"
  echo "4. Initialize git repository (if not already done)"
  echo "5. Commit extracted files"
fi

echo ""
echo "See dev-tools/reports/extraction-manifest.json for detailed file listing"
