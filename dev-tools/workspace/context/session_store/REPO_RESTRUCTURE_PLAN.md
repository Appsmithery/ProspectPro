# ProspectPro Repository Restructure Plan

**Version:** 1.0  
**Date:** 2025-11-01  
**Status:** Planning Phase

## Executive Summary

This document outlines the canonical roadmap for extracting portable development tooling from the ProspectPro monorepo into a separate Dev-Tools repository. The goal is to create reusable, app-agnostic automation, testing infrastructure, and agent workflows that can be shared across multiple projects while maintaining ProspectPro as a clean, focused application repository.

## Current State Analysis

### Repository Structure (As of 2025-11-01)

Based on the latest inventory scan, the repository consists of three primary domains:

1. **app/** (184 files) - Application code (frontend, backend, tests)
2. **dev-tools/** (318 files) - Development tooling, agents, automation
3. **integration/** (70 files) - Platform integrations, monitoring, infrastructure

### Key Observations

- **Portable components**: Most content under `dev-tools/agents/`, `dev-tools/automation/`, `dev-tools/testing/`, and `dev-tools/scripts/` is app-agnostic
- **App-specific wiring**: Some scripts in `dev-tools/scripts/automation/` reference ProspectPro-specific features (e.g., `integrate-highlight-edge-functions.ts`)
- **Legacy artifacts**: The recent scan removed temporary files (`.temp/`, `.task/`, `.deno_lsp/`) confirming cleanup is working
- **Integration dependencies**: Edge function deployment, Supabase CLI helpers, and Vercel configs currently live in both domains
- **Duplicate inventories**: Legacy inventory copies exist in `dev-tools/context/repo-GPS/` and `dev-tools/context/session_store/` that should be consolidated during cleanup phase

## Restructure Goals

1. **Separation of Concerns**: Extract portable dev tooling into a dedicated repository
2. **Reusability**: Enable other projects to leverage ProspectPro's mature development workflows
3. **Maintainability**: Reduce ProspectPro's surface area to core application code
4. **Traceability**: Maintain clear provenance and migration history

## Migration Phases

### Phase 1: Authoritative Inventories (CURRENT)

**Status:** ✅ Complete

- [x] Regenerate domain trees using `repo_scan.sh`
- [x] Refresh `app-filetree.txt`, `dev-tools-filetree.txt`, `integration-filetree.txt`
- [x] Document deltas in `coverage.md`
- [x] Create canonical roadmap (this document)

**Results:**
- All inventory files are current and reflect latest repo structure
- Temporary and build artifacts properly excluded from tracking
- 572 total tracked files across three domains

### Phase 2: Extraction Scope Definition

**Status:** 🔄 In Progress

#### Components to Extract

**Core Portable Assets** (to move to Dev-Tools repo):

```
dev-tools/
├── agents/                          # All agent profiles and workflows
│   ├── _development-workflow/
│   ├── _observability/
│   ├── _production-ops/
│   ├── _system-architect/
│   ├── client-service-layer/        # MCP service infrastructure
│   ├── context/                     # Agent context management
│   ├── mcp-servers/                 # MCP server implementations
│   └── scripts/                     # Agent automation scripts
├── automation/
│   └── ci-cd/                       # CI/CD automation (repo_scan, etc.)
├── testing/
│   ├── agents/                      # Agent test suites
│   ├── configs/                     # Vitest/Playwright configs
│   └── utils/                       # Test utilities and fixtures
├── scripts/
│   ├── automation/                  # Generic automation scripts
│   ├── setup/                       # Codespace bootstrap scripts
│   └── tooling/                     # Validation and config scripts
└── workspace/
    └── context/                     # Session store and inventories
```

**Archive Assets** (to move to Dev-Tools repo under `legacy/`):

```
archive/                             # Legacy configurations and backups
```

**App-Specific Wiring** (to keep in ProspectPro, expose via npm package):

```
dev-tools/scripts/automation/
├── integrate-highlight-edge-functions.ts    # ProspectPro-specific
└── vercel-validate.sh                       # ProspectPro deployment checks

integration/                                 # Platform-specific configs
└── (entire directory stays in ProspectPro)
```

#### Components to Retain in ProspectPro

```
app/                                 # All application code
config/                              # App configuration
docs/                                # ProspectPro documentation
integration/                         # Platform integrations
tests/                               # App-specific tests
scripts/                             # (if app-specific)
```

### Phase 3: Dev-Tools Repository Setup

**Status:** ⏳ Pending

**Tasks:**
- [ ] Create new `Dev-Tools` repository
- [ ] Initialize with portable agent profiles
- [ ] Copy portable automation scripts preserving directory structure
- [ ] Move legacy archives to `legacy/` bucket
- [ ] Create README with integration instructions
- [ ] Set up npm package for distribution

**Structure:**
```
Dev-Tools/
├── agents/                          # Portable agent profiles
├── automation/                      # CI/CD scripts
├── testing/                         # Test infrastructure
├── scripts/                         # Automation utilities
├── legacy/                          # Historical artifacts
├── docs/                            # Tooling documentation
├── package.json                     # npm package config
└── README.md                        # Integration guide
```

### Phase 4: ProspectPro Integration

**Status:** ⏳ Pending

**Tasks:**
- [ ] Add Dev-Tools as git submodule OR npm workspace entry
- [ ] Update `Taskfile.yml` to reference submodule paths
- [ ] Rewrite npm scripts to use Dev-Tools package
- [ ] Update VS Code settings for new paths
- [ ] Migrate app-specific scripts to thin wrappers

**Example Changes:**

**Before:**
```yaml
# Taskfile.yml
agents:test:
  cmds:
    - task: -d dev-tools/testing agents:test:full
```

**After:**
```yaml
# Taskfile.yml
agents:test:
  cmds:
    - task: -d dev-tools-package/ agents:test:full
```

### Phase 5: Cleanup and Validation

**Status:** ⏳ Pending

**Tasks:**
- [ ] Remove copied directories from ProspectPro
- [ ] Search for direct imports using ripgrep: `rg "dev-tools/" --type ts`
- [ ] Update import paths to use new integration surface
- [ ] Remove orphan documentation under `docs/dev-tools/`
- [ ] Run `npm run docs:update` to regenerate indexes
- [ ] Update `.env.example` with any new environment variables
- [ ] Remove duplicate inventory locations: `dev-tools/context/repo-GPS/` and `dev-tools/context/session_store/`
- [ ] Update any scripts referencing legacy inventory paths

**Validation Steps:**
- [ ] All npm scripts execute successfully
- [ ] VS Code tasks work from new paths
- [ ] Linting, building, and testing pass
- [ ] MCP servers start correctly
- [ ] Agent tests run through Taskfile
- [ ] Documentation builds without errors

### Phase 6: Documentation and Provenance

**Status:** ⏳ Pending

**Tasks:**
- [ ] Add migration summary to `settings-staging.md`
- [ ] Refresh `SYSTEM_REFERENCE.md` via `npm run docs:update`
- [ ] Document new directory structure in README
- [ ] Update Copilot instructions with new paths
- [ ] Record provenance in `coverage.md`
- [ ] Redact secrets from `.env.example`

## Automation Strategy

### Dry-Run Script

Create a migration dry-run script in Dev-Tools repo:

```bash
#!/usr/bin/env bash
# dev-tools/scripts/automation/migration-dry-run.sh

set -euo pipefail

echo "=== Dev-Tools Migration Dry Run ==="
echo "Validating extraction scope..."

# Check portable components
echo "✓ Checking agents/"
echo "✓ Checking automation/"
echo "✓ Checking testing/"

# Validate lint/test suite
echo "Running linters..."
npm run lint

echo "Running tests..."
npm test

# MCP health check
echo "Validating MCP servers..."
npm run mcp:test

echo "=== Dry run complete ==="
```

### Git Submodule Setup

**Option A: Git Submodule** (Recommended for tight coupling)

```bash
# In ProspectPro repo
git submodule add https://github.com/Appsmithery/Dev-Tools.git dev-tools-package
git submodule update --init --recursive

# Add to .gitmodules
[submodule "dev-tools-package"]
  path = dev-tools-package
  url = https://github.com/Appsmithery/Dev-Tools.git
  branch = main
```

**Guard Task:**
```yaml
# Taskfile.yml
check:submodule:
  cmds:
    - git submodule status
  silent: false
```

### NPM Workspace Entry

**Option B: NPM Workspace** (For more flexibility)

```json
// package.json
{
  "workspaces": [
    "app/frontend",
    "dev-tools-package"
  ]
}
```

## Integration Touchpoints

### Files Requiring Updates

1. **Taskfile.yml** - Update task paths to reference submodule
2. **package.json** - Update script paths and add workspace entry
3. **.vscode/settings.json** - Update MCP server paths
4. **.vscode/tasks.json** - Update task definitions
5. **.vscode/mcp_config.json** - Update server paths
6. **docs/tooling/settings-staging.md** - Document changes
7. **.github/copilot-instructions.md** - Update paths in instructions

### Import Path Updates

Search and replace patterns:

```bash
# Find all TypeScript imports
rg "from ['\"].*dev-tools/" --type ts

# Common patterns to replace:
# Before: from '../../../dev-tools/agents/...'
# After:  from '@prospectpro/dev-tools/agents/...'
```

## Highlight Integration Checklist

The `integrate-highlight-edge-functions.ts` script contains a checklist for validating telemetry after the move. Key validation points:

- [ ] Edge function telemetry still flows to Highlight.io
- [ ] OpenTelemetry spans are captured correctly
- [ ] Error reporting works from edge functions
- [ ] Agent telemetry sinks connect properly

## MCP Server Migration

### Manifest Regeneration

After moving MCP servers, regenerate manifests:

```bash
# Run in Dev-Tools repo
node scripts/mcp-chat-sync.js

# Output:
# - Updates agents-manifest.json
# - Rebuilds chatmode references
# - Validates tool registrations
```

### Server Paths

Update `.vscode/mcp_config.json`:

```json
{
  "mcpServers": {
    "utility": {
      "command": "node",
      "args": ["${workspaceFolder}/dev-tools-package/agents/mcp-servers/utility/dist/index.js"]
    }
  }
}
```

## Rollback Plan

If migration issues arise:

1. **Preserve Git History**: Keep archive branch before deletion
2. **Backup Package.json**: Store in `archive/config-backup/`
3. **Document Path Changes**: Track in `settings-staging.md`
4. **Validation Script**: Create rollback automation

```bash
#!/usr/bin/env bash
# scripts/rollback-migration.sh

echo "Rolling back Dev-Tools extraction..."

# Remove submodule
git submodule deinit dev-tools-package
git rm dev-tools-package

# Restore original dev-tools/
git checkout main -- dev-tools/

echo "Rollback complete. Run npm install."
```

## Success Criteria

Migration is complete when:

- [ ] Dev-Tools repo is standalone and portable
- [ ] ProspectPro integrates via submodule or npm package
- [ ] All CI/CD pipelines pass
- [ ] Documentation is updated and accurate
- [ ] Agent profiles work in both repos
- [ ] MCP servers start correctly
- [ ] No broken imports or missing files
- [ ] Telemetry and observability still function
- [ ] Team can develop in both repos without friction

## Timeline and Milestones

- **Week 1**: Complete Phase 1 (Inventories) ✅
- **Week 2**: Define extraction scope (Phase 2)
- **Week 3**: Create Dev-Tools repo (Phase 3)
- **Week 4**: Integrate into ProspectPro (Phase 4)
- **Week 5**: Cleanup and validation (Phase 5)
- **Week 6**: Documentation and rollout (Phase 6)

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken imports | High | Comprehensive search/replace, automated tests |
| CI/CD failures | High | Dry-run validation, rollback plan |
| Path resolution issues | Medium | Update all configs before removing files |
| Lost git history | Medium | Keep archive branch, document provenance |
| Team confusion | Low | Clear documentation, staged rollout |

## Open Questions

1. Should we use git submodule or npm workspace for integration?
   - **Recommendation**: Git submodule for better version locking
2. How do we handle app-specific agent extensions?
   - **Recommendation**: Keep in ProspectPro, import base profiles from Dev-Tools
3. What's the versioning strategy for Dev-Tools package?
   - **Recommendation**: Semantic versioning, major bumps for breaking changes

## Related Documents

- `coverage.md` - Migration provenance and deltas
- `settings-staging.md` - Configuration change staging
- `SUPABASE_MIGRATION.md` - Previous successful migration example
- `dev-tools/agents/context/MCP_MODE_TOOL_MATRIX.md` - MCP capabilities matrix

## Revision History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-11-01 | 1.0 | Copilot Agent | Initial plan created |
