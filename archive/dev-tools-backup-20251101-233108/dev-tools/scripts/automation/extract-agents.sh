#!/usr/bin/env bash
# dev-tools/scripts/automation/extract-agents.sh
#
# Extracts agent profiles and supporting infrastructure from ProspectPro
# to the Dev-Tools repository using rsync.

set -euo pipefail

PROSPECT_PRO_ROOT="${1:?Please provide ProspectPro repository path}"
DEV_TOOLS_ROOT="${2:?Please provide Dev-Tools repository path}"
DRY_RUN="${3:-false}"

RSYNC_OPTS="-av --progress"
if [ "$DRY_RUN" = "true" ]; then
  RSYNC_OPTS="$RSYNC_OPTS --dry-run"
  echo "=== DRY RUN MODE - No files will be copied ==="
fi

echo "=== Extracting Agent Profiles from ProspectPro ==="
echo "Source: $PROSPECT_PRO_ROOT"
echo "Target: $DEV_TOOLS_ROOT"
echo ""

# Validate source directories exist
if [ ! -d "$PROSPECT_PRO_ROOT/dev-tools/agents" ]; then
  echo "❌ Source directory not found: $PROSPECT_PRO_ROOT/dev-tools/agents"
  exit 1
fi

# Create target directory structure
mkdir -p "$DEV_TOOLS_ROOT/agents"

# Copy agent profiles (portable personas)
echo "1. Copying agent profiles..."
for agent in _development-workflow _observability _production-ops _system-architect; do
  if [ -d "$PROSPECT_PRO_ROOT/dev-tools/agents/$agent" ]; then
    echo "  Copying $agent..."
    rsync $RSYNC_OPTS \
      "$PROSPECT_PRO_ROOT/dev-tools/agents/$agent/" \
      "$DEV_TOOLS_ROOT/agents/$agent/"
  else
    echo "  ⚠ $agent not found, skipping"
  fi
done

# Copy shared agent infrastructure
echo ""
echo "2. Copying client-service-layer..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/agents/client-service-layer" ]; then
  rsync $RSYNC_OPTS \
    --exclude="node_modules" \
    --exclude="dist" \
    --exclude="*.tsbuildinfo" \
    "$PROSPECT_PRO_ROOT/dev-tools/agents/client-service-layer/" \
    "$DEV_TOOLS_ROOT/agents/client-service-layer/"
else
  echo "  ⚠ client-service-layer not found"
fi

echo ""
echo "3. Copying agent context (excluding session store working files)..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/agents/context" ]; then
  rsync $RSYNC_OPTS \
    --exclude="session_store/*.md" \
    --exclude="session_store/*.txt" \
    --exclude="session_store/*.log" \
    "$PROSPECT_PRO_ROOT/dev-tools/agents/context/" \
    "$DEV_TOOLS_ROOT/agents/context/"
else
  echo "  ⚠ context directory not found"
fi

echo ""
echo "4. Copying MCP servers..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/agents/mcp-servers" ]; then
  rsync $RSYNC_OPTS \
    --exclude="node_modules" \
    --exclude="dist" \
    --exclude="*.tsbuildinfo" \
    "$PROSPECT_PRO_ROOT/dev-tools/agents/mcp-servers/" \
    "$DEV_TOOLS_ROOT/agents/mcp-servers/"
else
  echo "  ⚠ mcp-servers not found"
fi

echo ""
echo "5. Copying agent scripts..."
if [ -d "$PROSPECT_PRO_ROOT/dev-tools/agents/scripts" ]; then
  rsync $RSYNC_OPTS \
    "$PROSPECT_PRO_ROOT/dev-tools/agents/scripts/" \
    "$DEV_TOOLS_ROOT/agents/scripts/"
else
  echo "  ⚠ agent scripts not found"
fi

# Copy base Taskfile if it exists
echo ""
echo "6. Copying Taskfile.base.yml..."
if [ -f "$PROSPECT_PRO_ROOT/dev-tools/agents/Taskfile.base.yml" ]; then
  cp "$PROSPECT_PRO_ROOT/dev-tools/agents/Taskfile.base.yml" \
     "$DEV_TOOLS_ROOT/agents/"
else
  echo "  ⚠ Taskfile.base.yml not found"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo ""
  echo "=== DRY RUN COMPLETE - No files were actually copied ==="
else
  echo ""
  echo "=== Agent extraction complete ==="
  echo ""
  echo "Next steps:"
  echo "1. cd $DEV_TOOLS_ROOT"
  echo "2. Verify all required files are present"
  echo "3. Run: npm install (if needed)"
  echo "4. Run: npm run build (if needed)"
fi
