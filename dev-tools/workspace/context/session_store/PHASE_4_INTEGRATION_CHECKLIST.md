# Phase 4 Integration Checklist

**Date:** 2025-11-01  
**Phase:** Phase 4 - ProspectPro Integration  
**Prerequisites:** Phase 3 extraction complete, Dev-Tools v1.0.0 tagged

## Overview

This checklist guides the integration of the extracted Dev-Tools repository back into ProspectPro as a git submodule or npm workspace dependency.

## Pre-Integration Verification

Before beginning integration, verify:

- [ ] Dev-Tools repository exists at https://github.com/Alextorelli/Dev-Tools
- [ ] `prospect-pro-tools` branch exists and is current
- [ ] v1.0.0 tag created on extracted code
- [ ] EXTRACTION_MANIFEST.md exists and is accurate
- [ ] Dev-Tools builds successfully (`npm install && npm run build`)
- [ ] Dev-Tools tests pass or skip gracefully (`npm test`)

## Integration Method Selection

Choose ONE of the following integration methods:

### Option A: Git Submodule (Recommended)

**Benefits:**
- Tight version control coupling
- Clear dependency relationship
- Easy to track which version is integrated
- Standard git workflow for updates

**Drawbacks:**
- Team must understand submodule commands
- Requires explicit submodule initialization
- Can be confusing for new contributors

### Option B: NPM Workspace

**Benefits:**
- Familiar npm workflow
- Easier for JavaScript developers
- Automatic dependency resolution
- Simpler CI/CD integration

**Drawbacks:**
- Less explicit version tracking
- Can accidentally use local changes
- May complicate monorepo tooling

## Git Submodule Integration (Option A)

### 1. Add Submodule

```bash
cd /path/to/ProspectPro

# Add Dev-Tools as submodule
git submodule add \
  -b prospect-pro-tools \
  https://github.com/Alextorelli/Dev-Tools.git \
  dev-tools-package

# Initialize submodule
git submodule update --init --recursive
```

**Verification:**
```bash
# Check submodule status
git submodule status

# Verify .gitmodules file
cat .gitmodules
```

### 2. Update .gitignore

```bash
# Ensure submodule artifacts are not tracked
echo "dev-tools-package/node_modules/" >> .gitignore
echo "dev-tools-package/dist/" >> .gitignore
echo "dev-tools-package/.env.local" >> .gitignore
```

### 3. Update package.json

Add reference to submodule for npm scripts:

```json
{
  "scripts": {
    "dev-tools:install": "cd dev-tools-package && npm install",
    "dev-tools:build": "cd dev-tools-package && npm run build",
    "dev-tools:test": "cd dev-tools-package && npm test",
    "postinstall": "npm run dev-tools:install && npm run dev-tools:build"
  }
}
```

**Or** add as workspace:

```json
{
  "workspaces": [
    "app/frontend",
    "dev-tools-package"
  ]
}
```

### 4. Update .vscode/mcp_config.json

Update all MCP server paths to reference submodule:

**Before:**
```json
{
  "mcpServers": {
    "utility": {
      "command": "node",
      "args": ["${workspaceFolder}/dev-tools/agents/mcp-servers/utility/dist/index.js"]
    }
  }
}
```

**After:**
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

**Checklist:**
- [ ] Update all `dev-tools/agents/mcp-servers/` paths
- [ ] Verify MCP servers start correctly
- [ ] Test MCP tools from VS Code

### 5. Update GitHub Workflows

Update `.github/workflows/mcp-agent-validation.yml`:

**Before:**
```yaml
- name: Validate MCP servers
  run: |
    cd dev-tools/agents/mcp-servers
    npm install
    npm test
```

**After:**
```yaml
- name: Initialize submodule
  run: git submodule update --init --recursive

- name: Validate MCP servers
  run: |
    cd dev-tools-package/agents/mcp-servers
    npm install
    npm test
```

Update `.github/workflows/docs-automation.yml`:

**Before:**
```yaml
- name: Run documentation scripts
  run: |
    bash dev-tools/automation/ci-cd/repo_scan.sh
```

**After:**
```yaml
- name: Initialize submodule
  run: git submodule update --init --recursive

- name: Run documentation scripts
  run: |
    bash dev-tools-package/automation/ci-cd/repo_scan.sh
```

**Checklist:**
- [ ] Update mcp-agent-validation.yml
- [ ] Update docs-automation.yml
- [ ] Add submodule initialization to all workflows
- [ ] Test workflows in CI

### 6. Update Taskfile.yml

**Before:**
```yaml
agents:test:
  cmds:
    - task: -d dev-tools/testing agents:test:full
```

**After:**
```yaml
agents:test:
  cmds:
    - task: -d dev-tools-package/testing agents:test:full
```

**Checklist:**
- [ ] Update all task paths referencing dev-tools
- [ ] Test tasks with `task --list`
- [ ] Verify task execution

### 7. Update VS Code Tasks

Update `.vscode/tasks.json`:

**Before:**
```json
{
  "label": "Validate MCP Servers",
  "command": "bash",
  "args": ["dev-tools/scripts/automation/validate-mcp.sh"]
}
```

**After:**
```json
{
  "label": "Validate MCP Servers",
  "command": "bash",
  "args": ["dev-tools-package/scripts/automation/validate-mcp.sh"]
}
```

**Checklist:**
- [ ] Update all task paths
- [ ] Test tasks from VS Code
- [ ] Verify task runner integration

### 8. Update Import Paths (if any)

Search for direct imports from dev-tools:

```bash
rg "from ['\"].*dev-tools/" --type ts --type tsx
```

Update to use package name (if configured):

**Before:**
```typescript
import { something } from '../../../dev-tools/agents/utils'
```

**After:**
```typescript
import { something } from '@prospectpro/dev-tools/agents/utils'
```

**Or** use relative path to submodule:

```typescript
import { something } from '../../../dev-tools-package/agents/utils'
```

**Checklist:**
- [ ] Search for dev-tools imports
- [ ] Update import paths
- [ ] Run TypeScript compiler
- [ ] Run linter

### 9. Create Submodule Guard Task

Add to `Taskfile.yml`:

```yaml
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

**Checklist:**
- [ ] Add submodule guard task
- [ ] Test with `task submodule:check`
- [ ] Add to CI workflow

## NPM Workspace Integration (Option B)

### 1. Add Workspace Reference

Update `package.json`:

```json
{
  "workspaces": [
    "app/frontend",
    "dev-tools-package"
  ]
}
```

### 2. Clone Dev-Tools Repository

```bash
cd /path/to/ProspectPro
git clone -b prospect-pro-tools \
  https://github.com/Alextorelli/Dev-Tools.git \
  dev-tools-package

# Add to .gitignore (entire directory)
echo "dev-tools-package/" >> .gitignore
```

### 3. Install Dependencies

```bash
npm install
```

npm will automatically link workspace dependencies.

### 4. Follow Steps 4-8 from Submodule Integration

All VS Code, workflow, and import path updates are the same.

## Post-Integration Validation

### 1. Build Validation

```bash
cd /path/to/ProspectPro

# Install dependencies (including submodule/workspace)
npm install

# Build all packages
npm run build

# Verify no errors
echo $?  # Should be 0
```

### 2. Lint Validation

```bash
# Run linter
npm run lint

# Should pass with no errors
```

### 3. Test Validation

```bash
# Run unit tests
npm test

# Run agent tests (if available)
npm run test:agents

# Run E2E tests (if available)
npm run test:e2e
```

### 4. MCP Server Validation

```bash
# Verify MCP servers start
cd dev-tools-package/agents/mcp-servers/utility
npm install
npm run build
node dist/index.js --test

# Should output: "✓ Utility MCP server self-test passed"
```

**Or from ProspectPro:**

```bash
# Using VS Code
# Open Command Palette (Cmd/Ctrl + Shift + P)
# Run: "Tasks: Run Task" -> "Validate MCP Servers"
```

### 5. Context Validation

```bash
# Validate agent contexts
npm run validate:contexts

# Should pass with no errors
```

### 6. CI/CD Validation

```bash
# Push changes to trigger CI
git add .
git commit -m "Integrate Dev-Tools as submodule"
git push

# Monitor CI workflows
# - mcp-agent-validation.yml should pass
# - docs-automation.yml should pass
```

### 7. Manual Testing

- [ ] Open VS Code and verify MCP servers connect
- [ ] Test agent profiles load correctly
- [ ] Verify task runner works with new paths
- [ ] Test documentation generation
- [ ] Verify telemetry/observability still works

## Documentation Updates

### 1. Update settings-staging.md

Document all configuration changes:

```markdown
## 2025-11-01: Dev-Tools Submodule Integration

### Changes:
- Added dev-tools-package as git submodule
- Updated .vscode/mcp_config.json paths
- Updated GitHub workflow paths
- Updated Taskfile.yml references
- Updated VS Code task paths

### Validation:
- ✅ All builds passing
- ✅ MCP servers operational
- ✅ Tests passing
- ✅ CI/CD workflows functional
```

### 2. Update coverage.md

Add Phase 4 completion entry with integration details.

### 3. Update REPO_RESTRUCTURE_PLAN.md

Mark Phase 4 as complete and update status.

### 4. Update README.md (Root)

Add section about Dev-Tools integration:

```markdown
## Development Tools

This project uses the [@prospectpro/dev-tools](https://github.com/Alextorelli/Dev-Tools) package for agent workflows, testing infrastructure, and automation scripts.

### Setup

The dev-tools are integrated as a git submodule. Initialize with:

\`\`\`bash
git submodule update --init --recursive
\`\`\`

### Updating

To update to the latest version:

\`\`\`bash
task submodule:update
# or
git submodule update --remote dev-tools-package
\`\`\`
```

## Rollback Plan

If integration issues arise:

### Rollback Submodule

```bash
# Remove submodule
git submodule deinit -f dev-tools-package
git rm -f dev-tools-package
rm -rf .git/modules/dev-tools-package

# Restore original dev-tools (if needed)
git checkout main -- dev-tools/

# Reinstall dependencies
npm install

# Revert configuration changes
git checkout HEAD~1 -- .vscode/mcp_config.json
git checkout HEAD~1 -- .github/workflows/
git checkout HEAD~1 -- Taskfile.yml
```

### Rollback Workspace

```bash
# Remove dev-tools-package
rm -rf dev-tools-package

# Restore original dev-tools (if needed)
git checkout main -- dev-tools/

# Remove workspace reference
# Edit package.json and remove dev-tools-package from workspaces

# Reinstall dependencies
npm install
```

## Common Issues

### Submodule Not Initialized

**Symptom:** `dev-tools-package/` directory is empty

**Solution:**
```bash
git submodule update --init --recursive
```

### MCP Servers Not Found

**Symptom:** VS Code cannot connect to MCP servers

**Solution:**
```bash
# Build MCP servers
cd dev-tools-package/agents/mcp-servers
npm install
npm run build

# Restart VS Code
```

### CI Workflow Fails

**Symptom:** GitHub Actions can't find files

**Solution:**
Add submodule initialization to workflow:
```yaml
- name: Initialize submodule
  run: git submodule update --init --recursive
```

### Import Errors

**Symptom:** TypeScript can't resolve imports

**Solution:**
```bash
# Update tsconfig paths
# Add to tsconfig.json:
{
  "compilerOptions": {
    "paths": {
      "@prospectpro/dev-tools/*": ["./dev-tools-package/*"]
    }
  }
}
```

## Success Criteria

Phase 4 is complete when:

- [ ] Dev-Tools integrated via submodule or workspace
- [ ] All builds pass (npm run build)
- [ ] All tests pass (npm test)
- [ ] Linter passes (npm run lint)
- [ ] MCP servers operational
- [ ] Agent profiles load correctly
- [ ] CI/CD workflows pass
- [ ] Documentation updated
- [ ] Team can develop without friction
- [ ] No broken imports or missing files

## Timeline

Estimated: 0.5 - 1 day

- [ ] Submodule/workspace setup: 30 minutes
- [ ] Configuration updates: 1-2 hours
- [ ] Testing and validation: 2-3 hours
- [ ] Documentation: 1 hour
- [ ] CI/CD verification: 1 hour

## Next Phase

After Phase 4 completion, proceed to **Phase 5: Cleanup and Validation**

- Remove extracted directories from ProspectPro
- Update remaining import paths
- Remove duplicate inventory locations
- Final validation sweep
- Team training/handoff
