# Phase 3 Execution Guide

**Date:** 2025-11-01  
**Status:** Ready for Execution  
**Prerequisites:** Phase 2 complete, all reports validated

## Quick Start

This guide provides the exact commands to execute Phase 3 of the repository restructure.

## Prerequisites Validation

Run this command to verify readiness:

```bash
cd /path/to/ProspectPro
bash dev-tools/scripts/automation/migration-dry-run.sh
```

**Expected output:**
- ✓ Core structure validated
- ✓ Phase 2 reports confirmed
- ⚠ Some checks may require manual review (expected)

## Phase 3: Step-by-Step Execution

### Step 1: Prepare Dev-Tools Repository

**Option A: Initialize new repository**

```bash
# Create and initialize Dev-Tools repository
git clone https://github.com/Alextorelli/Dev-Tools.git
cd Dev-Tools

# Create/checkout prospect-pro-tools branch
git checkout -b prospect-pro-tools || git checkout prospect-pro-tools

# Hard reset if branch exists and needs cleanup
git reset --hard
git clean -fdx
```

**Option B: Use existing repository**

```bash
# Navigate to existing Dev-Tools repository
cd /path/to/Dev-Tools

# Ensure on correct branch
git checkout prospect-pro-tools

# Hard reset to clean state
git reset --hard
git clean -fdx
```

### Step 2: Initialize Repository Skeleton

```bash
# From ProspectPro directory
cd /path/to/ProspectPro

# Run initialization script (dry-run first)
bash dev-tools/scripts/automation/init-devtools-repo.sh \
  /path/to/Dev-Tools \
  true

# Review output, then execute for real
bash dev-tools/scripts/automation/init-devtools-repo.sh \
  /path/to/Dev-Tools \
  false
```

**Verification:**
```bash
cd /path/to/Dev-Tools
ls -la

# Should see:
# - .git/
# - .gitignore
# - package.json
# - tsconfig.json
# - README.md
# - LICENSE
# - agents/ automation/ testing/ scripts/ workspace/ legacy/ docs/
```

**Commit skeleton:**
```bash
cd /path/to/Dev-Tools
git add .
git commit -m "chore: Initialize Dev-Tools repository skeleton

- Add base configuration files
- Set up directory structure
- Prepare for extraction from ProspectPro"
```

### Step 3: Run Full Extraction (Dry-Run First)

```bash
# From ProspectPro directory
cd /path/to/ProspectPro

# DRY RUN - Shows what will be extracted, no files copied
bash dev-tools/scripts/automation/run-full-extraction.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  true
```

**Review the output carefully:**
- Check which files will be copied
- Verify exclusions are correct
- Ensure no secrets or credentials are included

### Step 4: Execute Full Extraction

```bash
# From ProspectPro directory
cd /path/to/ProspectPro

# EXECUTE - Actually copies files
bash dev-tools/scripts/automation/run-full-extraction.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  false
```

**Expected output:**
- Phase 1: Extracting Agents Domain ✓
- Phase 2: Extracting Automation Domain ✓
- Phase 3: Extracting Scripts Domain ✓
- Phase 4: Extracting Testing Domain ✓
- Phase 5: Extracting Workspace Domain ✓

### Step 5: Validate Extraction

```bash
# Navigate to Dev-Tools
cd /path/to/Dev-Tools

# Check structure
tree -L 2

# Install dependencies
npm install

# Build packages
npm run build

# Run validation (may skip if tests not configured)
npm run validate || echo "Validation may require configuration"
```

### Step 6: Generate Extraction Manifest

```bash
cd /path/to/Dev-Tools

# Generate manifest
bash /path/to/ProspectPro/dev-tools/scripts/automation/generate-extraction-manifest.sh \
  . \
  EXTRACTION_MANIFEST.md

# Review manifest
cat EXTRACTION_MANIFEST.md
```

### Step 7: Commit Extracted Files

```bash
cd /path/to/Dev-Tools

# Review what was extracted
git status

# Add all files
git add .

# Commit
git commit -m "feat: Extract portable dev-tools from ProspectPro

Extracted components:
- Agent profiles: development-workflow, observability, production-ops, system-architect
- MCP servers: utility, client-service-layer
- Testing infrastructure: Vitest and Playwright configs, agent test suites
- Automation scripts: CI/CD, setup, validation
- Documentation: Agent guides, integration instructions

Excluded app-specific components:
- integrate-highlight-edge-functions.ts
- vercel-validate.sh
- deploy-highlight-integration.sh
- highlight-integration-inventory.sh
- observability/highlight-node/

Extracted from ProspectPro repository (Phase 3 of REPO_RESTRUCTURE_PLAN)
Source: https://github.com/Appsmithery/ProspectPro
Date: $(date +%Y-%m-%d)"
```

### Step 8: Tag Release

```bash
cd /path/to/Dev-Tools

# Create v1.0.0 tag
git tag -a v1.0.0 -m "Initial release of ProspectPro Dev-Tools

First stable release of extracted portable dev-tools.

Components:
- Agent profiles and workflows
- MCP server infrastructure
- Testing configurations
- Automation scripts
- Context management

See EXTRACTION_MANIFEST.md for full details."

# View tag
git show v1.0.0
```

### Step 9: Push to Remote

```bash
cd /path/to/Dev-Tools

# Push branch
git push origin prospect-pro-tools

# Push tag
git push origin v1.0.0

# Verify on GitHub
# https://github.com/Alextorelli/Dev-Tools/tree/prospect-pro-tools
```

### Step 10: Update ProspectPro Documentation

```bash
cd /path/to/ProspectPro

# Update REPO_RESTRUCTURE_PLAN.md status
# Change Phase 3 status from "Ready for Implementation" to "Complete"

# Update coverage.md
# Add Phase 3 completion entry with extraction details

# Update settings-staging.md
# Document completion of Phase 3
```

## Alternative: Individual Domain Extraction

If you need to extract domains one at a time instead of using the master script:

### Extract Agents Only

```bash
cd /path/to/ProspectPro

bash dev-tools/scripts/automation/extract-agents.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  true  # dry-run

# Review output, then execute
bash dev-tools/scripts/automation/extract-agents.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  false

# Validate
cd /path/to/Dev-Tools/agents
ls -la
```

### Extract Automation Only

```bash
bash dev-tools/scripts/automation/extract-automation.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  false
```

### Extract Scripts Only

```bash
bash dev-tools/scripts/automation/extract-scripts.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  false
```

### Extract Testing Only

```bash
bash dev-tools/scripts/automation/extract-testing.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  false
```

### Extract Workspace Only

```bash
bash dev-tools/scripts/automation/extract-workspace.sh \
  "$(pwd)" \
  /path/to/Dev-Tools \
  false
```

## Verification Checklist

After extraction, verify:

- [ ] All agent profiles present (4 profiles)
- [ ] MCP servers extracted (utility, etc.)
- [ ] Test configurations present
- [ ] Automation scripts present
- [ ] README.md exists and is accurate
- [ ] package.json has correct metadata
- [ ] tsconfig.json configured properly
- [ ] .gitignore excludes build artifacts
- [ ] No secrets or credentials included
- [ ] No node_modules or dist/ directories
- [ ] EXTRACTION_MANIFEST.md generated
- [ ] v1.0.0 tag created
- [ ] Branch pushed to GitHub

## Common Issues

### rsync Not Found

```bash
# Install rsync
# Ubuntu/Debian
sudo apt-get install rsync

# macOS
brew install rsync
```

### Permission Denied

```bash
# Make scripts executable
cd /path/to/ProspectPro
chmod +x dev-tools/scripts/automation/*.sh
```

### Directory Not Empty

If Dev-Tools directory already has content:

```bash
cd /path/to/Dev-Tools
git checkout prospect-pro-tools
git reset --hard
git clean -fdx
```

### Files Not Copying

Verify paths are absolute:

```bash
# Use $(pwd) for current directory
bash extract-agents.sh "$(pwd)" /full/path/to/Dev-Tools false
```

## Next Steps

After Phase 3 is complete:

1. **Verify extraction** - Review all extracted files
2. **Test build** - Ensure Dev-Tools builds successfully
3. **Review manifest** - Confirm EXTRACTION_MANIFEST.md is accurate
4. **Proceed to Phase 4** - Follow PHASE_4_INTEGRATION_CHECKLIST.md
5. **Update documentation** - Record completion in coverage.md

## Support Documents

- **REPO_RESTRUCTURE_PLAN.md** - Overall migration roadmap
- **MIGRATION_OPTIMIZATIONS.md** - Automation strategies
- **README-extraction-scripts.md** - Detailed script documentation
- **PHASE_4_INTEGRATION_CHECKLIST.md** - Next phase guidance
- **coverage.md** - Migration provenance

## Ready for Execution

All scripts are tested and production-ready. Follow the steps above to complete Phase 3 extraction.

---

**Generated:** 2025-11-01  
**For:** ProspectPro Repository Restructure Phase 3  
**By:** Automated extraction tooling
