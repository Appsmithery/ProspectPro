# Repository Restructure Migration Optimizations

**Date:** 2025-11-01  
**Related:** REPO_RESTRUCTURE_PLAN.md

## Overview

This document outlines additional optimizations and automation strategies to streamline the repository restructure process, based on existing patterns and tooling already present in the codebase.

## Automation Opportunities

### 1. Reuse Migration-Phase.sh Pattern

**Location:** `integration/infrastructure/scripts/migration-phase.sh`

**Current Usage:** Already sequences lint/tests plus MCP checks for validation

**Optimization:** Create a dry-run script in Dev-Tools repo that follows this proven pattern:

```bash
#!/usr/bin/env bash
# dev-tools/scripts/automation/migration-dry-run.sh

set -euo pipefail

echo "=== Dev-Tools Extraction Dry Run ==="

# Phase 1: Validate structure
echo "1. Validating portable components..."
for dir in agents automation testing scripts; do
  if [ -d "$dir" ]; then
    echo "  ✓ $dir/ exists"
  else
    echo "  ✗ $dir/ missing" && exit 1
  fi
done

# Phase 2: Run linters
echo "2. Running ESLint..."
npm run lint || exit 1

# Phase 3: Run test suite
echo "3. Running test suite..."
npm test || exit 1

# Phase 4: Validate MCP servers
echo "4. Validating MCP servers..."
npm run mcp:test || exit 1

# Phase 5: Check agent tests
echo "5. Running agent test suite..."
task agents:test:full || exit 1

# Phase 6: Validate inventories
echo "6. Checking inventories..."
bash dev-tools/automation/ci-cd/repo_scan.sh
git diff --exit-code dev-tools/workspace/context/session_store/*.txt || {
  echo "  ⚠ Inventories changed - review before proceeding"
}

echo "=== Dry run complete - ready for extraction ==="
```

**Benefits:**
- Validates entire extraction before making changes
- Prevents broken state in Dev-Tools repo
- Reuses existing automation patterns
- Can be run repeatedly during development

### 2. Git Submodule with Guard Task

**Location:** Root `Taskfile.yml`

**Optimization:** Add a guard task that runs in CI to prevent submodule pointer drift:

```yaml
# Taskfile.yml
submodule:check:
  desc: "Verify dev-tools submodule is current"
  cmds:
    - git submodule status
    - |
      if git submodule status | grep -q '^+'; then
        echo "⚠ Dev-Tools submodule is out of sync"
        echo "Run: git submodule update --remote"
        exit 1
      fi
  silent: false

submodule:update:
  desc: "Update dev-tools submodule to latest"
  cmds:
    - git submodule update --remote dev-tools-package
    - git add dev-tools-package
    - git commit -m "Update dev-tools submodule to latest"
```

**CI Integration:**

```yaml
# .github/workflows/ci.yml
jobs:
  validate:
    steps:
      - name: Check submodule status
        run: task submodule:check
```

**Benefits:**
- Automatic detection of out-of-sync submodules
- Prevents CI failures from stale references
- Self-documenting update procedure
- Enforces team discipline around updates

### 3. MCP Manifest Auto-Regeneration

**Location:** `dev-tools/agents/scripts/mcp-chat-sync.js`

**Current Usage:** Manually rebuilds chatmode manifests

**Optimization:** Wire into post-move automation:

```bash
#!/usr/bin/env bash
# dev-tools/scripts/automation/post-migration-sync.sh

echo "=== Post-Migration MCP Sync ==="

# Regenerate MCP manifests
echo "1. Regenerating MCP manifests..."
node dev-tools/agents/scripts/mcp-chat-sync.js

# Validate chatmode references
echo "2. Validating chatmodes..."
node dev-tools/agents/scripts/mcp-chat-validate.js

# Update VS Code MCP config
echo "3. Checking VS Code config..."
if grep -q '"dev-tools/agents/mcp-servers"' .vscode/mcp_config.json; then
  echo "  ⚠ Update .vscode/mcp_config.json to reference dev-tools-package/"
fi

# Refresh inventories
echo "4. Refreshing inventories..."
bash dev-tools/automation/ci-cd/repo_scan.sh

echo "=== Sync complete ==="
```

**Benefits:**
- Ensures MCP manifests stay current after moves
- Validates chatmode wiring automatically
- Reduces manual coordination steps
- Prevents stale references in agent configs

### 4. Highlight Integration Validation

**Location:** `dev-tools/scripts/automation/integrate-highlight-edge-functions.ts`

**Current Feature:** Contains checklist for telemetry validation

**Optimization:** Extract validation logic into standalone script:

```typescript
#!/usr/bin/env -S deno run --allow-net --allow-env
// dev-tools/scripts/validation/validate-highlight-integration.ts

import { H } from '@highlight-run/node';

interface ValidationResult {
  success: boolean;
  message: string;
}

async function validateEdgeTelemetry(): Promise<ValidationResult[]> {
  const results: ValidationResult[] = [];
  
  // 1. Check environment variables
  const requiredEnv = ['HIGHLIGHT_PROJECT_ID', 'SUPABASE_URL'];
  for (const env of requiredEnv) {
    results.push({
      success: !!Deno.env.get(env),
      message: `Environment variable ${env}`
    });
  }
  
  // 2. Test Highlight connectivity
  try {
    H.init({ projectID: Deno.env.get('HIGHLIGHT_PROJECT_ID')! });
    results.push({
      success: true,
      message: 'Highlight.io SDK initialized'
    });
  } catch (e) {
    results.push({
      success: false,
      message: `Highlight.io init failed: ${e.message}`
    });
  }
  
  // 3. Validate OpenTelemetry spans
  // ... additional checks
  
  return results;
}

const results = await validateEdgeTelemetry();
const failures = results.filter(r => !r.success);

if (failures.length > 0) {
  console.error('❌ Highlight integration validation failed:');
  failures.forEach(f => console.error(`  - ${f.message}`));
  Deno.exit(1);
}

console.log('✅ Highlight integration validated successfully');
```

**Benefits:**
- Automated post-migration telemetry check
- Catches integration breaks early
- Can run in CI pipeline
- Reduces manual verification burden

### 5. Import Path Migration Script

**Optimization:** Automated search-and-replace for TypeScript imports:

```bash
#!/usr/bin/env bash
# dev-tools/scripts/automation/migrate-import-paths.sh

set -euo pipefail

echo "=== Migrating Import Paths ==="

# Find all TypeScript files with dev-tools imports
FILES=$(rg -l "from ['\"].*dev-tools/" --type ts --glob '!node_modules/**')

if [ -z "$FILES" ]; then
  echo "No import paths to migrate"
  exit 0
fi

echo "Found $(echo "$FILES" | wc -l) files with dev-tools imports"

# Backup before modification
BACKUP_DIR="/tmp/import-migration-backup-$(date +%s)"
mkdir -p "$BACKUP_DIR"
echo "$FILES" | xargs -I {} cp {} "$BACKUP_DIR/"

# Replace import paths
echo "Migrating paths..."
echo "$FILES" | xargs sed -i \
  -e 's|from "../../../dev-tools/|from "@prospectpro/dev-tools/|g' \
  -e 's|from "../../dev-tools/|from "@prospectpro/dev-tools/|g' \
  -e 's|from "../dev-tools/|from "@prospectpro/dev-tools/|g'

# Validate syntax
echo "Validating TypeScript syntax..."
npm run lint || {
  echo "❌ Lint failed - restoring backup from $BACKUP_DIR"
  echo "$FILES" | xargs -I {} cp "$BACKUP_DIR/{}" {}
  exit 1
}

echo "✅ Import paths migrated successfully"
echo "Backup available at: $BACKUP_DIR"
```

**Benefits:**
- Automates tedious search-and-replace
- Validates syntax before committing
- Creates safety backup
- Reduces human error

### 6. Documentation Sync Automation

**Optimization:** Auto-update documentation after file moves:

```bash
#!/usr/bin/env bash
# dev-tools/scripts/automation/sync-docs-after-migration.sh

echo "=== Syncing Documentation ==="

# 1. Regenerate inventories
echo "1. Regenerating inventories..."
npm run repo:scan

# 2. Update system reference
echo "2. Updating system reference..."
npm run docs:update

# 3. Refresh Mermaid diagrams
echo "3. Refreshing diagrams..."
npm run docs:prepare

# 4. Validate documentation links
echo "4. Checking broken links..."
for doc in docs/**/*.md; do
  if grep -q 'dev-tools/' "$doc"; then
    echo "  ⚠ $doc may need path updates"
  fi
done

# 5. Update settings-staging.md
echo "5. Updating settings-staging.md..."
cat >> docs/tooling/settings-staging.md <<EOF

## $(date +%Y-%m-%d): Dev-Tools Extraction Complete

### Changes:
- Extracted portable dev-tools to separate repository
- Updated all import paths to use @prospectpro/dev-tools
- Configured git submodule at dev-tools-package/
- Validated all automation and test suites

### Validation:
- ✅ All tests passing
- ✅ MCP servers operational
- ✅ Documentation updated
- ✅ CI/CD pipelines functional

EOF

echo "=== Documentation sync complete ==="
```

**Benefits:**
- Ensures documentation stays current
- Catches broken links early
- Logs changes in staging document
- Single command for full sync

### 7. Rollback Automation

**Optimization:** One-command rollback script:

```bash
#!/usr/bin/env bash
# dev-tools/scripts/automation/rollback-extraction.sh

set -euo pipefail

echo "⚠️  WARNING: This will rollback the dev-tools extraction"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Rollback cancelled"
  exit 0
fi

echo "=== Rolling Back Dev-Tools Extraction ==="

# 1. Remove submodule
echo "1. Removing submodule..."
git submodule deinit -f dev-tools-package
git rm -f dev-tools-package
rm -rf .git/modules/dev-tools-package

# 2. Restore original dev-tools/
echo "2. Restoring original dev-tools..."
git checkout main -- dev-tools/

# 3. Restore original package.json
echo "3. Restoring package.json..."
cp archive/config-backup/package.json.pre-extraction package.json

# 4. Restore original Taskfile
echo "4. Restoring Taskfile.yml..."
git checkout main -- Taskfile.yml

# 5. Reinstall dependencies
echo "5. Reinstalling dependencies..."
npm install

# 6. Validate state
echo "6. Validating rollback..."
npm run lint && npm test

echo "✅ Rollback complete"
echo "Note: You may need to manually restore some files from backup"
```

**Benefits:**
- One-command rollback
- Safe restoration procedure
- Validates post-rollback state
- Reduces panic during issues

## Best Practices from Existing Migrations

### Supabase Migration Success Factors

From `SUPABASE_MIGRATION.md` and recent coverage.md entries:

1. **Comprehensive validation** - Test every changed script
2. **Incremental updates** - Update scripts before removing files
3. **Documentation first** - Create migration guide before executing
4. **Rollback tarball** - Create archive before destructive changes
5. **Path validation** - Verify all references updated via grep/ripgrep

### Agent Test Suite Consolidation Lessons

From coverage.md Agent Test Suite Consolidation section:

1. **Unified Taskfile** - Single orchestration point for all tests
2. **Centralized fixtures** - Shared test data reduces duplication
3. **Config wrappers** - Vitest/Playwright configs abstract complexity
4. **Deterministic seeding** - setup.ts ensures reproducible tests

## Execution Sequence

Recommended order for applying optimizations:

1. **Week 1-2: Preparation**
   - Create dry-run validation script
   - Set up backup/rollback procedures
   - Document current import paths

2. **Week 3: Extraction**
   - Run dry-run validation
   - Create Dev-Tools repository
   - Copy portable components
   - Run validation again in new repo

3. **Week 4: Integration**
   - Set up git submodule
   - Run import path migration script
   - Add submodule guard task
   - Update documentation

4. **Week 5: Validation**
   - Run full test suite
   - Validate MCP servers
   - Check Highlight integration
   - Run post-migration sync

5. **Week 6: Cleanup**
   - Remove extracted directories
   - Archive legacy locations
   - Update all documentation
   - Final validation pass

## Success Metrics

Track these metrics to gauge migration success:

- ✅ All CI/CD pipelines pass (target: 100%)
- ✅ No broken imports (ripgrep shows 0 matches for old paths)
- ✅ Test coverage maintained or improved
- ✅ MCP servers start without errors
- ✅ Highlight telemetry flowing (validate via dashboard)
- ✅ Documentation builds cleanly
- ✅ Team can develop without friction

## Maintenance After Migration

### Regular Checks

Add to weekly/monthly ops checklist:

```bash
# Weekly: Verify submodule is current
task submodule:check

# Monthly: Validate dev-tools integration
npm run validate:contexts
npm run mcp:test
npm test
```

### Update Procedure

When Dev-Tools repo updates:

```bash
# Update submodule pointer
task submodule:update

# Validate changes
npm run lint
npm test
task agents:test:full

# Commit and push
git push origin main
```

## Related Resources

- `REPO_RESTRUCTURE_PLAN.md` - Overall migration roadmap
- `coverage.md` - Historical migration provenance
- `SUPABASE_MIGRATION.md` - Successful migration example
- `integration/infrastructure/scripts/migration-phase.sh` - Existing validation pattern
- `dev-tools/agents/scripts/mcp-chat-sync.js` - MCP manifest generator
- `.vscode/TASKS_REFERENCE.md` - Available automation tasks

## Conclusion

These optimizations leverage existing patterns and tooling already present in the ProspectPro codebase. By reusing proven automation from previous migrations and creating targeted scripts for the extraction process, we can minimize risk and reduce manual effort while maintaining high quality standards.

The key is to automate validation at every step, maintain comprehensive backups, and document everything for future reference.
