# Phase 3 Extraction Scripts

This directory contains automated scripts for extracting portable dev-tools from ProspectPro into a separate Dev-Tools repository.

## Overview

The extraction process is divided into modular scripts that handle different domains sequentially. Each script supports dry-run mode for safe testing before actual execution.

## Scripts

### 1. Repository Initialization

**`init-devtools-repo.sh`** - Initializes the Dev-Tools repository skeleton

```bash
# Dry run (shows what would be created)
bash dev-tools/scripts/automation/init-devtools-repo.sh /path/to/dev-tools true

# Actual execution
bash dev-tools/scripts/automation/init-devtools-repo.sh /path/to/dev-tools false
```

Creates:
- `.gitignore` (Node.js, Deno, build artifacts)
- `package.json` (npm workspace configuration)
- `tsconfig.json` (TypeScript configuration)
- `README.md` (integration guide)
- `LICENSE` (MIT license)
- Directory structure for all domains

### 2. Domain Extraction Scripts

Each extraction script follows the same pattern:

```bash
bash <script> <source-repo> <target-repo> [dry-run]
```

**`extract-agents.sh`** - Extracts agent profiles and MCP infrastructure

```bash
bash dev-tools/scripts/automation/extract-agents.sh \
  /path/to/ProspectPro \
  /path/to/Dev-Tools \
  true  # dry-run mode
```

Extracts:
- Agent profiles (_development-workflow, _observability, _production-ops, _system-architect)
- Client service layer
- Agent context (excluding session store working files)
- MCP servers (excluding node_modules and build artifacts)
- Agent scripts
- Taskfile.base.yml

**`extract-automation.sh`** - Extracts CI/CD automation

```bash
bash dev-tools/scripts/automation/extract-automation.sh \
  /path/to/ProspectPro \
  /path/to/Dev-Tools \
  true
```

Extracts:
- CI/CD scripts (repo_scan.sh, etc.)
- Automation utilities

**`extract-scripts.sh`** - Extracts portable scripts (excludes app-specific)

```bash
bash dev-tools/scripts/automation/extract-scripts.sh \
  /path/to/ProspectPro \
  /path/to/Dev-Tools \
  true
```

Extracts:
- Generic automation scripts
- Setup and bootstrap scripts
- Tooling and validation scripts

Excludes:
- `integrate-highlight-edge-functions.ts`
- `vercel-validate.sh`
- `deploy-highlight-integration.sh`
- `highlight-integration-inventory.sh`

**`extract-testing.sh`** - Extracts test infrastructure

```bash
bash dev-tools/scripts/automation/extract-testing.sh \
  /path/to/ProspectPro \
  /path/to/Dev-Tools \
  true
```

Extracts:
- Test configurations (Vitest, Playwright)
- Agent test suites
- Test utilities and fixtures
- Testing README

**`extract-workspace.sh`** - Extracts workspace context

```bash
bash dev-tools/scripts/automation/extract-workspace.sh \
  /path/to/ProspectPro \
  /path/to/Dev-Tools \
  true
```

Extracts:
- Workspace context (excluding transient files)
- Moves archives to legacy/ directory

Excludes:
- Session store working files (*.md, *.txt, *.log)
- Diagnostics directories

### 3. Full Extraction Orchestration

**`run-full-extraction.sh`** - Runs all extraction scripts in sequence

```bash
# Dry run (tests entire extraction process)
bash dev-tools/scripts/automation/run-full-extraction.sh \
  /path/to/ProspectPro \
  /path/to/Dev-Tools \
  true

# Actual extraction
bash dev-tools/scripts/automation/run-full-extraction.sh \
  /path/to/ProspectPro \
  /path/to/Dev-Tools \
  false
```

Orchestrates:
1. Phase 1: Extract Agents
2. Phase 2: Extract Automation
3. Phase 3: Extract Scripts
4. Phase 4: Extract Testing
5. Phase 5: Extract Workspace

### 4. Post-Extraction Documentation

**`generate-extraction-manifest.sh`** - Generates EXTRACTION_MANIFEST.md

```bash
bash dev-tools/scripts/automation/generate-extraction-manifest.sh \
  /path/to/Dev-Tools \
  EXTRACTION_MANIFEST.md
```

Generates comprehensive documentation including:
- Extraction statistics
- Directory structure
- Extracted components
- Excluded components
- Dependencies
- Integration points
- Validation checklist

### 5. Validation

**`migration-dry-run.sh`** - Validates extraction readiness

```bash
bash dev-tools/scripts/automation/migration-dry-run.sh
```

Validates:
- Portable component structure
- Phase 2 reports presence
- Linting (if dependencies installed)
- Test suite (if available)
- MCP servers (if configured)
- Agent tests (if Task CLI available)
- Inventories (regenerates and checks for changes)
- TypeScript configuration

## Execution Workflow

### Recommended Sequence

1. **Pre-Extraction Validation**
   ```bash
   cd /path/to/ProspectPro
   bash dev-tools/scripts/automation/migration-dry-run.sh
   ```

2. **Initialize Dev-Tools Repository**
   ```bash
   bash dev-tools/scripts/automation/init-devtools-repo.sh \
     /path/to/Dev-Tools \
     false
   ```

3. **Dry-Run Full Extraction** (Safety Check)
   ```bash
   bash dev-tools/scripts/automation/run-full-extraction.sh \
     /path/to/ProspectPro \
     /path/to/Dev-Tools \
     true
   ```

4. **Execute Full Extraction**
   ```bash
   bash dev-tools/scripts/automation/run-full-extraction.sh \
     /path/to/ProspectPro \
     /path/to/Dev-Tools \
     false
   ```

5. **Generate Manifest**
   ```bash
   cd /path/to/Dev-Tools
   bash /path/to/ProspectPro/dev-tools/scripts/automation/generate-extraction-manifest.sh \
     . \
     EXTRACTION_MANIFEST.md
   ```

6. **Validate Extraction**
   ```bash
   cd /path/to/Dev-Tools
   npm install
   npm run build
   npm run validate
   ```

7. **Commit and Tag**
   ```bash
   cd /path/to/Dev-Tools
   git add .
   git commit -m "feat: Initial extraction from ProspectPro"
   git tag v1.0.0
   git push origin prospect-pro-tools --tags
   ```

## Dry-Run Mode

All extraction scripts support dry-run mode via a third parameter:

- `true` = Dry-run mode (show what would be done, no files copied)
- `false` or omitted = Execute mode (actually copy files)

**Always run dry-run first** to validate the extraction process before executing.

## Safety Features

1. **Exclusions**: Automatically excludes node_modules, build artifacts, and transient files
2. **Validation**: Each script validates source directories before extraction
3. **Progress Output**: Detailed console output shows what's being extracted
4. **Rollback**: Git history preserved in both repositories
5. **Dry-Run**: Test extraction without modifying files

## Integration with ProspectPro

After extraction, ProspectPro must be updated to reference the new Dev-Tools location:

### Files to Update

1. `.vscode/mcp_config.json` - Update MCP server paths to `dev-tools-package/`
2. `.github/workflows/mcp-agent-validation.yml` - Update workflow paths
3. `.github/workflows/docs-automation.yml` - Update documentation paths
4. `package.json` - Add submodule or workspace reference
5. `Taskfile.yml` - Update task paths to reference submodule

### Integration Script

See `REPO_RESTRUCTURE_PLAN.md` Phase 4 for detailed integration steps.

## Troubleshooting

### Script Fails with "Source directory not found"

Ensure you're providing absolute paths to both repositories:

```bash
bash extract-agents.sh \
  /home/user/ProspectPro \
  /home/user/Dev-Tools \
  false
```

### Rsync Warnings

Rsync may warn about pre-existing files. This is normal and can be ignored if running extraction multiple times.

### Missing Dependencies

Some scripts require:
- `rsync` (file copying)
- `tree` (directory visualization - optional)
- `git` (version control)

Install via your package manager if missing.

## Related Documentation

- **REPO_RESTRUCTURE_PLAN.md** - Overall migration roadmap
- **MIGRATION_OPTIMIZATIONS.md** - Automation strategies and best practices
- **coverage.md** - Phase 2 completion details and provenance
- **dev-tools/reports/extraction-manifest.json** - File-by-file categorization
- **dev-tools/reports/phase-3-readiness-summary.md** - Pre-extraction validation

## Notes

- All scripts use `set -euo pipefail` for strict error handling
- Scripts are idempotent - safe to run multiple times
- Extraction preserves file permissions and timestamps
- Git submodule integration is recommended over npm workspace for tight coupling
- Remember to update ProspectPro's `.gitignore` to exclude submodule artifacts

## Support

For questions or issues, refer to:
- Phase 3 section of `REPO_RESTRUCTURE_PLAN.md`
- `MIGRATION_OPTIMIZATIONS.md` for automation patterns
- Phase 2 reports in `dev-tools/reports/`
