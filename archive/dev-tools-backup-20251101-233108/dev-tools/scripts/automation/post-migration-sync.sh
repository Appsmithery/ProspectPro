#!/usr/bin/env bash
# dev-tools/scripts/automation/post-migration-sync.sh
#
# Synchronizes MCP manifests, validates chatmode wiring, and refreshes inventories
# after repository restructure or dev-tools extraction
#
# Usage: bash dev-tools/scripts/automation/post-migration-sync.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
cd "$REPO_ROOT"

echo "=== Post-Migration MCP Sync ==="
echo "Repository: $REPO_ROOT"
echo ""

# Check if we're in ProspectPro or Dev-Tools repo
if [ -f "package.json" ] && grep -q "prospectpro-verified-business-intelligence" package.json; then
  REPO_TYPE="ProspectPro"
else
  REPO_TYPE="Dev-Tools"
fi

echo "Repository type: $REPO_TYPE"
echo ""

# Phase 1: Regenerate MCP manifests
echo "1. Regenerating MCP manifests..."
if [ -f "dev-tools/agents/scripts/mcp-chat-sync.js" ]; then
  if node dev-tools/agents/scripts/mcp-chat-sync.js 2>/dev/null; then
    echo "  ✓ MCP manifests regenerated"
  else
    echo "  ⚠ MCP manifest regeneration failed or not configured"
  fi
else
  echo "  ⚠ mcp-chat-sync.js not found - skipping"
fi
echo ""

# Phase 2: Validate chatmode references
echo "2. Validating chatmode references..."
if [ -f "dev-tools/agents/scripts/mcp-chat-validate.js" ]; then
  if node dev-tools/agents/scripts/mcp-chat-validate.js 2>/dev/null; then
    echo "  ✓ Chatmode references validated"
  else
    echo "  ⚠ Chatmode validation failed or returned warnings"
  fi
else
  echo "  ⚠ mcp-chat-validate.js not found - skipping"
fi
echo ""

# Phase 3: Check VS Code MCP config paths
echo "3. Checking VS Code MCP config..."
if [ -f ".vscode/mcp_config.json" ]; then
  if [ "$REPO_TYPE" = "ProspectPro" ]; then
    # Check if paths still reference local dev-tools
    if grep -q '"dev-tools/agents/mcp-servers"' .vscode/mcp_config.json; then
      echo "  ⚠ Update .vscode/mcp_config.json to reference dev-tools-package/ or submodule path"
      echo "     Current paths point to local dev-tools (may need update after extraction)"
    else
      echo "  ✓ MCP config paths appear updated"
    fi
  else
    echo "  ✓ MCP config exists"
  fi
else
  echo "  ⚠ .vscode/mcp_config.json not found"
fi
echo ""

# Phase 4: Refresh inventories
echo "4. Refreshing inventories..."
if [ -f "dev-tools/automation/ci-cd/repo_scan.sh" ]; then
  if bash dev-tools/automation/ci-cd/repo_scan.sh 2>/dev/null; then
    echo "  ✓ Inventories refreshed"
    
    # Check for changes
    if git diff --exit-code dev-tools/workspace/context/session_store/*.txt 2>/dev/null; then
      echo "  ✓ Inventories unchanged"
    else
      echo "  ⚠ Inventories changed - review and commit updates"
    fi
  else
    echo "  ⚠ Inventory refresh failed"
  fi
else
  echo "  ⚠ repo_scan.sh not found - skipping inventory refresh"
fi
echo ""

# Phase 5: Update documentation (optional)
echo "5. Documentation update..."
if [ "$REPO_TYPE" = "ProspectPro" ]; then
  if npm run docs:update 2>/dev/null; then
    echo "  ✓ Documentation updated"
  else
    echo "  ⚠ Documentation update failed or not configured"
  fi
else
  echo "  ⓘ Documentation update skipped for Dev-Tools repo"
fi
echo ""

# Summary
echo "=== Sync Complete ==="
echo ""
echo "Next steps:"
if [ "$REPO_TYPE" = "ProspectPro" ]; then
  echo "1. Review .vscode/mcp_config.json for path updates"
  echo "2. Review inventory changes and commit if needed"
  echo "3. Test MCP server connectivity with updated paths"
  echo "4. Run migration-dry-run.sh to validate state"
else
  echo "1. Verify all MCP servers are accessible"
  echo "2. Test agent profiles with new structure"
  echo "3. Commit any inventory or manifest updates"
fi
