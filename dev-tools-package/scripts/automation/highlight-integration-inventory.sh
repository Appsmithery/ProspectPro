#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
REPORT_FILE="$REPO_ROOT/dev-tools/reports/highlight-integration-inventory.md"

echo "# Highlight Node Integration Inventory" > "$REPORT_FILE"
echo "Generated: $(date -Iseconds)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "## Edge Functions Requiring Integration" >> "$REPORT_FILE"
find "$REPO_ROOT/app/backend/functions" -name "index.ts" -type f | while read -r func; do
  func_name=$(basename "$(dirname "$func")")
  if ! grep -q "withHighlightEdge\|initHighlightNode" "$func"; then
    echo "- [ ] $func_name" >> "$REPORT_FILE"
  else
    echo "- [x] $func_name (already integrated)" >> "$REPORT_FILE"
  fi
done

echo "" >> "$REPORT_FILE"
echo "## MCP Servers Requiring Integration" >> "$REPORT_FILE"
find "$REPO_ROOT/dev-tools/agents/mcp-servers" -name "index.ts" -o -name "server.ts" | while read -r server; do
  server_name=$(basename "$(dirname "$server")")
  if ! grep -q "initHighlightNode" "$server" 2>/dev/null; then
    echo "- [ ] $server_name" >> "$REPORT_FILE"
  else
    echo "- [x] $server_name (already integrated)" >> "$REPORT_FILE"
  fi
done

echo "" >> "$REPORT_FILE"
echo "## Agent Profiles Requiring Config Updates" >> "$REPORT_FILE"
find "$REPO_ROOT/dev-tools/agents" -maxdepth 1 -type d -name "_*" | while read -r agent; do
  agent_name=$(basename "$agent")
  echo "- [ ] $agent_name" >> "$REPORT_FILE"
done

cat "$REPORT_FILE"
