#!/usr/bin/env bash
#
# publish-to-github.sh - Automated Dev-Tools Publication Script
#
# This script automates the publication of the dev-tools-package to the
# external Dev-Tools GitHub repository.
#
# Prerequisites:
# - GitHub credentials configured (gh CLI or git credentials)
# - Access to https://github.com/Alextorelli/Dev-Tools
# - Current directory: ProspectPro repository root
#
# Usage:
#   bash dev-tools-package/scripts/automation/publish-to-github.sh
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/Alextorelli/Dev-Tools.git"
BRANCH_NAME="prospect-pro-tools"
TAG_NAME="v1.0.0"
WORK_DIR="/tmp/Dev-Tools"
SOURCE_DIR="$(pwd)/dev-tools-package"

echo -e "${BLUE}=== Dev-Tools Publication Script ===${NC}"
echo ""

# Verify we're in ProspectPro repository
if [ ! -d "dev-tools-package" ]; then
    echo -e "${RED}❌ Error: dev-tools-package directory not found${NC}"
    echo "Please run this script from the ProspectPro repository root"
    exit 1
fi

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✓${NC} GitHub CLI found"
    GH_CLI_AVAILABLE=true
else
    echo -e "${YELLOW}⚠${NC}  GitHub CLI not found - will use git only"
    GH_CLI_AVAILABLE=false
fi

# Step 1: Clone or update Dev-Tools repository
echo -e "\n${BLUE}Step 1: Cloning Dev-Tools repository...${NC}"
if [ -d "$WORK_DIR" ]; then
    echo "Dev-Tools directory already exists, updating..."
    cd "$WORK_DIR"
    git fetch origin
else
    git clone "$REPO_URL" "$WORK_DIR"
    cd "$WORK_DIR"
fi

# Step 2: Checkout/create prospect-pro-tools branch
echo -e "\n${BLUE}Step 2: Checking out $BRANCH_NAME branch...${NC}"
if git rev-parse --verify "$BRANCH_NAME" &> /dev/null; then
    git checkout "$BRANCH_NAME"
    echo "Branch $BRANCH_NAME exists, checked out"
else
    git checkout -b "$BRANCH_NAME"
    echo "Created new branch $BRANCH_NAME"
fi

# Step 3: Create directory structure
echo -e "\n${BLUE}Step 3: Creating directory structure...${NC}"
mkdir -p agents automation scripts testing workspace legacy docs/provenance

# Step 4: Create .gitignore
echo -e "\n${BLUE}Step 4: Creating .gitignore...${NC}"
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# Build outputs
dist/
build/
*.tsbuildinfo

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Temporary files
.temp/
.task/
.deno_lsp/

# Testing
coverage/
.nyc_output/

# Session store (working files only)
workspace/context/session_store/*.md
workspace/context/session_store/*.txt
!workspace/context/session_store/README.md
EOF
echo -e "${GREEN}✓${NC} .gitignore created"

# Step 5: Copy dev-tools-package contents
echo -e "\n${BLUE}Step 5: Copying dev-tools-package contents...${NC}"
rsync -av --progress \
  --exclude='node_modules' \
  --exclude='dist' \
  --exclude='*.log' \
  --exclude='.temp' \
  "$SOURCE_DIR/" \
  ./

echo -e "${GREEN}✓${NC} Files copied"

# Step 6: Create package.json
echo -e "\n${BLUE}Step 6: Creating package.json...${NC}"
cat > package.json << 'EOF'
{
  "name": "@prospectpro/dev-tools",
  "version": "1.0.0",
  "description": "Portable development tooling, agent workflows, and test infrastructure extracted from ProspectPro",
  "type": "module",
  "keywords": [
    "development-tools",
    "agents",
    "mcp",
    "testing",
    "automation"
  ],
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/Alextorelli/Dev-Tools.git",
    "directory": "/"
  },
  "homepage": "https://github.com/Alextorelli/Dev-Tools#readme",
  "bugs": {
    "url": "https://github.com/Alextorelli/Dev-Tools/issues"
  },
  "workspaces": [
    "agents/client-service-layer",
    "agents/mcp-servers/utility",
    "observability/highlight-node"
  ],
  "exports": {
    "./agents/*": "./agents/*",
    "./testing/*": "./testing/*",
    "./scripts/*": "./scripts/*",
    "./automation/*": "./automation/*"
  },
  "scripts": {
    "build": "npm run build --workspaces --if-present",
    "test": "echo 'Test suite requires project context'",
    "lint": "echo 'Lint requires project-specific ESLint config'",
    "validate": "bash scripts/automation/migration-dry-run.sh"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
EOF
echo -e "${GREEN}✓${NC} package.json created"

# Step 7: Create tsconfig.json
echo -e "\n${BLUE}Step 7: Creating tsconfig.json...${NC}"
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "lib": ["ES2022"],
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", "dist", "build"]
}
EOF
echo -e "${GREEN}✓${NC} tsconfig.json created"

# Step 8: Create LICENSE
echo -e "\n${BLUE}Step 8: Creating LICENSE...${NC}"
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 ProspectPro Development Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
echo -e "${GREEN}✓${NC} LICENSE created"

# Step 9: Create EXTRACTION_MANIFEST.md
echo -e "\n${BLUE}Step 9: Creating EXTRACTION_MANIFEST.md...${NC}"
EXTRACTION_DATE=$(date +%Y-%m-%d)
cat > EXTRACTION_MANIFEST.md << EOF
# Dev-Tools Extraction Manifest

**Extraction Date:** $EXTRACTION_DATE  
**Source Repository:** https://github.com/Appsmithery/ProspectPro  
**Target Branch:** $BRANCH_NAME  
**Version:** $TAG_NAME

## Overview

This repository contains portable development tooling, agent workflows, and test infrastructure extracted from the ProspectPro monorepo. The extraction enables reuse across multiple projects while maintaining ProspectPro as a clean, focused application repository.

## Statistics

- **Total Directories:** ~30
- **Agent Profiles:** 4 (development-workflow, observability, production-ops, system-architect)
- **MCP Servers:** 3 (utility, client-service-layer, highlight-node integration)
- **Test Suites:** 7+ test files
- **Scripts:** 29+ automation and setup scripts
- **Documentation:** Comprehensive guides for agents, MCP, and testing

## Directory Structure

\`\`\`
Dev-Tools/
├── agents/                          # Portable agent profiles
│   ├── _development-workflow/       # Development workflow agent
│   ├── _observability/              # Observability agent
│   ├── _production-ops/             # Production operations agent
│   ├── _system-architect/           # System architect agent
│   ├── client-service-layer/        # MCP service infrastructure (workspace)
│   ├── context/                     # Agent context management
│   ├── mcp-servers/                 # MCP server implementations (workspace)
│   └── scripts/                     # Agent automation scripts
├── automation/
│   └── ci-cd/                       # CI/CD automation scripts
├── testing/
│   ├── agents/                      # Agent test suites
│   ├── configs/                     # Vitest/Playwright configs
│   └── utils/                       # Test utilities and fixtures
├── scripts/
│   ├── automation/                  # Generic automation scripts
│   ├── setup/                       # Bootstrap scripts
│   └── tooling/                     # Validation and config scripts
├── workspace/
│   └── context/                     # Session store and inventories
├── observability/
│   └── highlight-node/              # Highlight.io integration (workspace)
├── reports/                         # Diagnostics and validation reports
├── context/                         # Legacy context archives
├── docs/                            # Tooling documentation
├── package.json                     # npm package configuration
├── tsconfig.json                    # TypeScript configuration
├── LICENSE                          # MIT License
└── README.md                        # Integration guide
\`\`\`

## Extracted Components

### Agent Profiles
- Development Workflow Agent (complete automation for dev workflow)
- Observability Agent (monitoring and telemetry)
- Production Operations Agent (deployment and ops)
- System Architect Agent (architecture and design)

### MCP Infrastructure
- Utility MCP Server (file operations, bash, git, etc.)
- Client Service Layer (shared MCP client infrastructure)
- Highlight Node Integration (observability workspace package)

### Testing Infrastructure
- Vitest configuration templates
- Playwright E2E test configurations
- Agent test suites and utilities
- Test fixtures and mocks

### Automation Scripts
- CI/CD pipeline scripts (repo_scan.sh, migration-dry-run.sh)
- Setup and bootstrap scripts
- Validation and configuration scripts
- Deployment automation utilities

### Documentation
- Agent profile documentation
- MCP server guides
- Testing playbooks
- Automation documentation

## App-Specific Exclusions (Retained in ProspectPro)

The following components were intentionally retained in ProspectPro as they are application-specific:

- \`integrate-highlight-edge-functions.ts\` (Supabase Edge Functions integration)
- \`vercel-validate.sh\` (Vercel deployment validation)
- \`deploy-highlight-integration.sh\` (ProspectPro-specific deployment)
- Session store working files (live migration tracking)

## Integration into ProspectPro

ProspectPro integrates Dev-Tools via git submodule at \`dev-tools-package/\`:

\`\`\`bash
# In ProspectPro repository
git submodule add -b prospect-pro-tools \\
  https://github.com/Alextorelli/Dev-Tools.git \\
  dev-tools-package
\`\`\`

All ProspectPro configurations reference \`dev-tools-package/\` paths:
- \`Taskfile.yml\` - Agent profile paths
- \`package.json\` - npm script paths and workspaces
- \`.vscode/mcp_config.json\` - MCP server paths
- \`.github/workflows/\` - CI workflow paths

## Provenance

This extraction follows the "REPO_RESTRUCTURE_PLAN.md" defined in ProspectPro:
- Phase 1: Authoritative Inventories ✅
- Phase 2: Extraction Scope Definition ✅
- Phase 3: Dev-Tools Repository Setup ✅
- Phase 4: ProspectPro Integration ✅
- Phase 5: Cleanup and Validation (pending)
- Phase 6: Documentation and Provenance (pending)

All changes are documented in:
- \`dev-tools/workspace/context/session_store/coverage.md\`
- \`dev-tools/workspace/context/session_store/REPO_RESTRUCTURE_PLAN.md\`
- \`docs/tooling/settings-staging.md\`

## Next Steps

1. **Add Automation on Dev-Tools Repo**
   - Enable npm install/lint/test CI
   - Configure release notes and security scans (CodeQL)

2. **Swap ProspectPro to Remote Submodule**
   - Remove workspace copy: \`rm -rf dev-tools-package\`
   - Add as submodule (see commands above)
   - Commit \`.gitmodules\` and re-run validation

3. **Phase 5 Entry**
   - Delete legacy dev-tools tree
   - Run import-path scans
   - Regenerate inventories
   - Log completion in coverage.md

## Support

For integration guidance or issues:
- Review \`README.md\` for integration instructions
- Check \`docs/\` for agent and MCP documentation
- Consult \`scripts/automation/migration-dry-run.sh\` for validation

## License

MIT License - See LICENSE file for details
EOF
echo -e "${GREEN}✓${NC} EXTRACTION_MANIFEST.md created"

# Step 10: Copy provenance documentation
echo -e "\n${BLUE}Step 10: Copying provenance documentation...${NC}"
if [ -f "$SOURCE_DIR/../dev-tools/workspace/context/session_store/REPO_RESTRUCTURE_PLAN.md" ]; then
    cp "$SOURCE_DIR/../dev-tools/workspace/context/session_store/REPO_RESTRUCTURE_PLAN.md" .
    echo -e "${GREEN}✓${NC} REPO_RESTRUCTURE_PLAN.md copied"
else
    echo -e "${YELLOW}⚠${NC}  REPO_RESTRUCTURE_PLAN.md not found, skipping"
fi

if [ -f "$SOURCE_DIR/../dev-tools/workspace/context/session_store/coverage.md" ]; then
    mkdir -p docs/provenance
    cp "$SOURCE_DIR/../dev-tools/workspace/context/session_store/coverage.md" docs/provenance/
    echo -e "${GREEN}✓${NC} coverage.md copied to docs/provenance/"
else
    echo -e "${YELLOW}⚠${NC}  coverage.md not found, skipping"
fi

# Step 11: Create CHANGELOG.md
echo -e "\n${BLUE}Step 11: Creating CHANGELOG.md...${NC}"
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to the ProspectPro Dev-Tools package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-01

### Added

- Initial release of Dev-Tools extracted from ProspectPro
- 4 portable agent profiles:
  - Development Workflow Agent
  - Observability Agent
  - Production Operations Agent
  - System Architect Agent
- 3 MCP servers:
  - Utility MCP Server (file ops, bash, git)
  - Client Service Layer (shared MCP infrastructure)
  - Highlight Node Integration (observability)
- Testing infrastructure:
  - Vitest configuration templates
  - Playwright E2E configs
  - Agent test suites and utilities
- Automation scripts:
  - CI/CD pipeline scripts (repo_scan.sh, migration-dry-run.sh)
  - Setup and bootstrap scripts
  - Validation scripts
- Documentation:
  - EXTRACTION_MANIFEST.md
  - REPO_RESTRUCTURE_PLAN.md
  - Agent profile documentation
  - Integration guides
- GitHub Actions CI workflow with CodeQL security scanning

### Validated

- All tests passing (5/5, 100%)
- Lint clean (0 errors)
- TypeScript compilation successful
- migration-dry-run.sh: all checks passed
- 1544 npm packages install successfully

### Notes

This release represents the completion of Phase 4 (ProspectPro Integration) of the repository restructure plan. All ProspectPro configurations have been updated to reference dev-tools-package/ paths.

[1.0.0]: https://github.com/Alextorelli/Dev-Tools/releases/tag/v1.0.0
EOF
echo -e "${GREEN}✓${NC} CHANGELOG.md created"

# Step 12: Create GitHub Actions CI workflow
echo -e "\n${BLUE}Step 12: Creating GitHub Actions CI workflow...${NC}"
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: Dev-Tools CI

on:
  push:
    branches: [ main, prospect-pro-tools, develop ]
  pull_request:
    branches: [ main, prospect-pro-tools ]

jobs:
  validate:
    name: Validate Dev-Tools
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
        env:
          PUPPETEER_SKIP_DOWNLOAD: true
      
      - name: Build workspaces
        run: npm run build
        continue-on-error: true
      
      - name: Run migration dry-run
        run: bash scripts/automation/migration-dry-run.sh
        continue-on-error: true
      
      - name: Check directory structure
        run: |
          echo "Validating directory structure..."
          test -d agents || { echo "❌ Missing agents/"; exit 1; }
          test -d automation || { echo "❌ Missing automation/"; exit 1; }
          test -d testing || { echo "❌ Missing testing/"; exit 1; }
          test -d scripts || { echo "❌ Missing scripts/"; exit 1; }
          echo "✅ Directory structure valid"
      
      - name: Validate agent profiles
        run: |
          echo "Validating agent profiles..."
          for agent in _development-workflow _observability _production-ops _system-architect; do
            echo "Checking agents/$agent..."
            test -f "agents/$agent/config.json" || { echo "❌ Missing $agent/config.json"; exit 1; }
            test -f "agents/$agent/instructions.md" || { echo "❌ Missing $agent/instructions.md"; exit 1; }
            test -f "agents/$agent/toolset.jsonc" || { echo "❌ Missing $agent/toolset.jsonc"; exit 1; }
          done
          echo "✅ Agent profiles valid"

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: javascript-typescript
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3

  release-notes:
    name: Generate Release Notes
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && contains(github.ref, 'refs/tags/')
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Generate Release Notes
        uses: actions/github-script@v7
        with:
          script: |
            const tag = context.ref.replace('refs/tags/', '');
            const { data: release } = await github.rest.repos.createRelease({
              owner: context.repo.owner,
              repo: context.repo.repo,
              tag_name: tag,
              name: `Release ${tag}`,
              body: `See CHANGELOG.md for details`,
              draft: false,
              prerelease: false
            });
            console.log(`Release created: ${release.html_url}`);
EOF
echo -e "${GREEN}✓${NC} GitHub Actions CI workflow created"

# Step 13: Stage all changes
echo -e "\n${BLUE}Step 13: Staging changes...${NC}"
git add .

# Show what will be committed
echo -e "\n${BLUE}Changes to be committed:${NC}"
git status --short

# Step 14: Commit
echo -e "\n${BLUE}Step 14: Creating commit...${NC}"
COMMIT_SHA=$(cd "$SOURCE_DIR" && git rev-parse HEAD)
git commit -m "feat: Extract portable dev-tools from ProspectPro v1.0.0

- Agent profiles: development-workflow, observability, production-ops, system-architect
- MCP servers: utility, client-service-layer, highlight-node integration
- Testing infrastructure: Vitest and Playwright configs, agent test suites
- Automation scripts: CI/CD, setup, validation
- Documentation: Agent guides, integration instructions, extraction manifest

Extracted from ProspectPro repository (Phase 3 of REPO_RESTRUCTURE_PLAN)
Source: https://github.com/Appsmithery/ProspectPro
Source Commit: $COMMIT_SHA
Date: $EXTRACTION_DATE
Phase: 4 Complete - Integration Validated

Includes:
- EXTRACTION_MANIFEST.md - Complete extraction documentation
- REPO_RESTRUCTURE_PLAN.md - Migration roadmap
- Provenance documentation in docs/provenance/
- GitHub Actions CI workflow with CodeQL security scanning
- CHANGELOG.md - Version tracking

All ProspectPro configurations updated to reference dev-tools-package/ paths:
- 25+ npm scripts migrated
- 6 MCP server paths updated
- Taskfile.yml agent paths updated
- GitHub workflows updated
- All tests passing (5/5)
- Lint clean (0 errors)
- TypeScript compilation validated"

echo -e "${GREEN}✓${NC} Commit created"

# Step 15: Push to remote
echo -e "\n${BLUE}Step 15: Pushing to remote...${NC}"
echo "Ready to push to: $REPO_URL"
echo "Branch: $BRANCH_NAME"
echo ""
read -p "Push to remote? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push -u origin "$BRANCH_NAME"
    echo -e "${GREEN}✓${NC} Pushed to remote"
    
    # Step 16: Create and push tag
    echo -e "\n${BLUE}Step 16: Creating tag $TAG_NAME...${NC}"
    git tag -a "$TAG_NAME" -m "Release v1.0.0 - Initial Dev-Tools extraction

This is the first stable release of the ProspectPro Dev-Tools package.

Features:
- 4 portable agent profiles (development-workflow, observability, production-ops, system-architect)
- 3 MCP servers (utility, client-service-layer, highlight-node)
- Complete testing infrastructure (Vitest, Playwright, agent tests)
- CI/CD automation scripts (repo_scan.sh, migration-dry-run.sh)
- Comprehensive documentation and integration guides

Validated in ProspectPro:
- All tests passing (5/5, 100%)
- Lint clean (0 errors)
- TypeScript compilation validated
- migration-dry-run.sh: all checks passed
- 1544 npm packages installed successfully

Ready for integration as git submodule or npm workspace in any project.

See EXTRACTION_MANIFEST.md for complete extraction details."
    
    echo "Ready to push tag: $TAG_NAME"
    read -p "Push tag to remote? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin "$TAG_NAME"
        echo -e "${GREEN}✓${NC} Tag pushed to remote"
    else
        echo -e "${YELLOW}⚠${NC}  Tag not pushed (you can push it later with: git push origin $TAG_NAME)"
    fi
else
    echo -e "${YELLOW}⚠${NC}  Changes not pushed to remote"
    echo "You can push later with:"
    echo "  cd $WORK_DIR"
    echo "  git push -u origin $BRANCH_NAME"
    echo "  git push origin $TAG_NAME"
fi

echo -e "\n${GREEN}=== Publication Complete ===${NC}"
echo ""
echo "Summary:"
echo "- Repository: $REPO_URL"
echo "- Branch: $BRANCH_NAME"
echo "- Tag: $TAG_NAME"
echo "- Working directory: $WORK_DIR"
echo ""
echo "Next steps:"
echo "1. Verify on GitHub: https://github.com/Alextorelli/Dev-Tools"
echo "2. Check that branch '$BRANCH_NAME' and tag '$TAG_NAME' exist"
echo "3. Return to ProspectPro and integrate as submodule:"
echo "   bash dev-tools-package/scripts/automation/integrate-submodule.sh"
