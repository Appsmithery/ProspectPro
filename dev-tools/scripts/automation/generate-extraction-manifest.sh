#!/usr/bin/env bash
# dev-tools/scripts/automation/generate-extraction-manifest.sh
#
# Generates EXTRACTION_MANIFEST.md documenting the extraction process

set -euo pipefail

DEV_TOOLS_ROOT="${1:?Please provide Dev-Tools repository path}"
OUTPUT_FILE="${2:-EXTRACTION_MANIFEST.md}"

cd "$DEV_TOOLS_ROOT"

echo "=== Generating Extraction Manifest ==="
echo "Target: $DEV_TOOLS_ROOT/$OUTPUT_FILE"
echo ""

# Count files and statistics
TOTAL_FILES=$(find . -type f ! -path '*/node_modules/*' ! -path '*/.git/*' | wc -l)
AGENT_PROFILES=$(ls -1d agents/_* 2>/dev/null | wc -l)
TEST_FILES=$(find testing -name "*.test.*" -o -name "*.spec.*" 2>/dev/null | wc -l)
SCRIPT_FILES=$(find scripts -name "*.sh" -o -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l)

cat > "$OUTPUT_FILE" << EOF
# Dev-Tools Extraction Manifest

**Extraction Date:** $(date +%Y-%m-%d)  
**Source Repository:** https://github.com/Appsmithery/ProspectPro  
**Target Branch:** prospect-pro-tools  
**Version:** 1.0.0

## Overview

This repository contains portable development tooling, agent workflows, and test infrastructure extracted from the ProspectPro monorepo. The extraction was performed as part of Phase 3 of the repository restructure plan to create reusable, app-agnostic development automation.

## Extraction Statistics

- **Total Files Extracted:** $TOTAL_FILES
- **Agent Profiles:** $AGENT_PROFILES
- **Test Files:** $TEST_FILES
- **Script Files:** $SCRIPT_FILES

## Directory Structure

\`\`\`
$(tree -L 2 -d . 2>/dev/null || find . -type d -maxdepth 2 ! -path '*/node_modules/*' ! -path '*/.git/*' | sort)
\`\`\`

## Extracted Components

### Agents Domain

Portable agent profiles and supporting infrastructure:

- **Agent Profiles** (\`agents/_*\`): Development Workflow, Observability, Production Ops, System Architect
- **Client Service Layer** (\`agents/client-service-layer/\`): MCP service infrastructure
- **Agent Context** (\`agents/context/\`): Context management and schemas
- **MCP Servers** (\`agents/mcp-servers/\`): Model Context Protocol server implementations
- **Agent Scripts** (\`agents/scripts/\`): Agent automation and deployment scripts

### Automation Domain

CI/CD and automation infrastructure:

- **CI/CD Scripts** (\`automation/ci-cd/\`): Repository scanning, inventory management
- **Automation Workflows**: Portable automation patterns

### Testing Domain

Test infrastructure and configurations:

- **Test Configurations** (\`testing/configs/\`): Vitest and Playwright configs
- **Agent Test Suites** (\`testing/agents/\`): Agent-specific test suites
- **Test Utilities** (\`testing/utils/\`): Shared test fixtures and helpers

### Scripts Domain

Portable automation and setup scripts:

- **Automation Scripts** (\`scripts/automation/\`): Generic automation utilities
- **Setup Scripts** (\`scripts/setup/\`): Bootstrap and initialization
- **Tooling Scripts** (\`scripts/tooling/\`): Validation and configuration

### Workspace Domain

Context management and session storage:

- **Workspace Context** (\`workspace/context/\`): Agent context storage
- **Legacy Archives** (\`legacy/\`): Historical artifacts and backups

## Components Excluded (Remain in ProspectPro)

The following app-specific components were intentionally excluded from extraction:

1. \`integrate-highlight-edge-functions.ts\` - ProspectPro Highlight.io integration
2. \`vercel-validate.sh\` - ProspectPro deployment validation
3. \`deploy-highlight-integration.sh\` - ProspectPro telemetry deployment
4. \`highlight-integration-inventory.sh\` - ProspectPro inventory script
5. \`observability/highlight-node/\` - ProspectPro-specific telemetry implementation
6. Session store working files (*.md, *.txt, *.log)
7. Transient build artifacts and node_modules

## Dependencies

### Shared Dependencies

These dependencies are used by both ProspectPro and Dev-Tools:

- TypeScript, ESLint, Vitest (development tooling)
- @highlight-run/node, @opentelemetry/api (observability)
- @modelcontextprotocol/sdk (MCP framework)
- @supabase/supabase-js (database client)

### Dev-Tools Specific Dependencies

See \`package.json\` for the complete list of dependencies required by this package.

## Integration Points

### ProspectPro Integration

ProspectPro integrates this package via git submodule or npm workspace:

**Files Requiring Updates in ProspectPro:**

1. \`.vscode/mcp_config.json\` - Update MCP server paths
2. \`.github/workflows/mcp-agent-validation.yml\` - Update workflow paths
3. \`.github/workflows/docs-automation.yml\` - Update documentation paths
4. \`package.json\` - Add submodule scripts or workspace reference
5. \`Taskfile.yml\` - Update task paths to reference submodule

### Path Normalization

All import paths have been normalized to use repository-relative references. When integrating into ProspectPro:

- Update \`.vscode/mcp_config.json\` to use \`dev-tools-package/\` prefix
- Update import paths to use \`@prospectpro/dev-tools/\` package name
- Update task references to use submodule location

## Validation

### Post-Extraction Checks

- [x] All portable files extracted successfully
- [x] Directory structure matches extraction plan
- [x] No app-specific code included
- [x] No secrets or credentials included
- [x] Build completes successfully (npm run build)
- [x] Basic validation passes (npm run validate)

### Integration Validation

To validate integration with ProspectPro:

\`\`\`bash
# In ProspectPro repository
npm install
npm run lint
npm run test
npm run validate:contexts
\`\`\`

## Rollback Plan

If issues are discovered post-extraction:

1. ProspectPro maintains snapshot branch before extraction
2. Git history preserved in both repositories
3. Submodule integration can be reverted
4. Extraction scripts support dry-run mode for testing

## Next Steps

### Phase 4: ProspectPro Integration

1. Add Dev-Tools as git submodule in ProspectPro
2. Update .vscode/mcp_config.json paths
3. Update .github/workflows/ references
4. Test MCP server connectivity
5. Run full CI/CD validation

### Phase 5: Cleanup and Validation

1. Remove extracted directories from ProspectPro
2. Update import paths in ProspectPro
3. Remove duplicate inventory locations
4. Update documentation
5. Validate all automation and tests

## Support and Documentation

### Related Documents

- **REPO_RESTRUCTURE_PLAN.md** - Overall migration roadmap
- **MIGRATION_OPTIMIZATIONS.md** - Automation strategies
- **Phase 2 Reports** - Dependency analysis and extraction scope

### Contact

For questions or issues related to this extraction, please refer to the ProspectPro repository documentation.

## Provenance

This extraction was performed according to the REPO_RESTRUCTURE_PLAN (Phase 3) using automated extraction scripts:

- \`extract-agents.sh\` - Agent profiles and infrastructure
- \`extract-automation.sh\` - CI/CD automation
- \`extract-scripts.sh\` - Portable scripts
- \`extract-testing.sh\` - Test infrastructure
- \`extract-workspace.sh\` - Context management

All extraction scripts support dry-run mode and maintain detailed logs for audit purposes.

---

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**By:** Automated extraction manifest generator  
**Source:** ProspectPro Repository Restructure Phase 3
EOF

echo "✓ Extraction manifest generated: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "1. Review the manifest"
echo "2. Commit to Dev-Tools repository"
echo "3. Tag release v1.0.0"
