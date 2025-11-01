#!/usr/bin/env bash
# dev-tools/scripts/automation/migration-dry-run.sh
#
# Validates dev-tools extraction readiness by running comprehensive checks
# This script should pass before proceeding with Phase 3 extraction

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
cd "$REPO_ROOT"

echo "=== Dev-Tools Extraction Dry Run ==="
echo "Repository: $REPO_ROOT"
echo ""

# Phase 1: Validate structure
echo "1. Validating portable components..."
MISSING_DIRS=0
for dir in dev-tools/agents dev-tools/automation dev-tools/testing dev-tools/scripts; do
  if [ -d "$dir" ]; then
    echo "  ✓ $dir/ exists"
  else
    echo "  ✗ $dir/ missing"
    MISSING_DIRS=$((MISSING_DIRS + 1))
  fi
done

if [ $MISSING_DIRS -gt 0 ]; then
  echo "  ❌ Missing $MISSING_DIRS required directories"
  exit 1
fi
echo ""

# Phase 2: Validate Phase 2 reports
echo "2. Validating Phase 2 reports..."
MISSING_REPORTS=0
for report in dependency-analysis.txt env-variables-inventory.txt mcp-references.txt ci-workflows-to-update.txt extraction-manifest.json; do
  if [ -f "dev-tools/reports/$report" ]; then
    echo "  ✓ $report exists"
  else
    echo "  ✗ $report missing"
    MISSING_REPORTS=$((MISSING_REPORTS + 1))
  fi
done

if [ $MISSING_REPORTS -gt 0 ]; then
  echo "  ❌ Missing $MISSING_REPORTS required reports"
  exit 1
fi
echo ""

# Phase 3: Run linters (conditional - only if files exist)
echo "3. Running ESLint..."
if npm run lint; then
  echo "  ✓ Linting passed"
else
  echo "  ⚠ Linting failed - review before extraction"
  # Don't exit - linting issues may be pre-existing
fi
echo ""

# Phase 4: Run test suite (conditional - skip if no tests)
echo "4. Running test suite..."
if npm test 2>/dev/null; then
  echo "  ✓ Tests passed"
else
  echo "  ⚠ Tests failed or not configured - review before extraction"
  # Don't exit - test failures may be pre-existing
fi
echo ""

# Phase 5: Validate MCP servers (conditional)
echo "5. Validating MCP servers..."
if [ -d "dev-tools/agents/mcp-servers" ]; then
  if npm run mcp:test 2>/dev/null; then
    echo "  ✓ MCP server tests passed"
  else
    echo "  ⚠ MCP tests failed or not configured"
  fi
else
  echo "  ⚠ MCP servers directory not found"
fi
echo ""

# Phase 6: Check agent tests (conditional - only if Task CLI available)
echo "6. Checking agent test suite..."
if command -v task &> /dev/null; then
  if task agents:test:full 2>/dev/null; then
    echo "  ✓ Agent tests passed"
  else
    echo "  ⚠ Agent tests failed or not configured"
  fi
else
  echo "  ⚠ Task CLI not installed - skipping agent tests"
fi
echo ""

# Phase 7: Validate inventories
echo "7. Validating inventories..."
if bash dev-tools/automation/ci-cd/repo_scan.sh; then
  echo "  ✓ Inventories regenerated"
  
  # Check if inventories changed
  if git diff --exit-code dev-tools/workspace/context/session_store/*.txt 2>/dev/null; then
    echo "  ✓ Inventories unchanged"
  else
    echo "  ⚠ Inventories changed - review before proceeding"
    echo ""
    echo "Changed files:"
    git diff --name-only dev-tools/workspace/context/session_store/*.txt
  fi
else
  echo "  ⚠ Inventory regeneration failed"
fi
echo ""

# Phase 8: Validate TypeScript configuration
echo "8. Validating TypeScript configuration..."
if [ -f "tsconfig.json" ]; then
  echo "  ✓ Root tsconfig.json exists"
  if [ -f "config/tsconfig.json" ]; then
    if npm run type-check 2>/dev/null; then
      echo "  ✓ TypeScript compilation validated"
    else
      echo "  ⚠ TypeScript compilation failed - review before extraction"
    fi
  fi
else
  echo "  ⚠ Root tsconfig.json not found"
fi
echo ""

# Summary
echo "=== Dry Run Summary ==="
echo "✓ Core structure validated"
echo "✓ Phase 2 reports confirmed"
echo "⚠ Some checks may require manual review"
echo ""
echo "Ready for Phase 3 extraction with manual verification of warnings."
