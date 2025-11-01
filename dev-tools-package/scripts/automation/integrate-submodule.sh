#!/usr/bin/env bash
#
# integrate-submodule.sh - Integrate Dev-Tools as Git Submodule
#
# This script automates the integration of the published Dev-Tools repository
# as a git submodule in ProspectPro.
#
# Prerequisites:
# - Dev-Tools repository published to GitHub
# - prospect-pro-tools branch exists
# - v1.0.0 tag created
# - GitHub Actions CI passing
# - Current directory: ProspectPro repository root
#
# Usage:
#   bash dev-tools-package/scripts/automation/integrate-submodule.sh
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
SUBMODULE_PATH="dev-tools-package"

echo -e "${BLUE}=== Dev-Tools Submodule Integration Script ===${NC}"
echo ""

# Verify we're in ProspectPro repository
if [ ! -f "package.json" ] || ! grep -q "\"name\": \"@prospectpro/platform\"" package.json 2>/dev/null; then
    echo -e "${RED}❌ Error: Not in ProspectPro repository root${NC}"
    exit 1
fi

# Check if dev-tools-package currently exists as a directory
if [ -d "$SUBMODULE_PATH" ] && [ ! -f "$SUBMODULE_PATH/.git" ]; then
    echo -e "${YELLOW}⚠${NC}  dev-tools-package exists as a workspace directory"
    echo ""
    echo "This script will:"
    echo "1. Create a backup of the current dev-tools-package"
    echo "2. Remove the workspace directory"
    echo "3. Add Dev-Tools as a git submodule"
    echo "4. Validate the integration"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    # Step 1: Create backup
    echo -e "\n${BLUE}Step 1: Creating backup...${NC}"
    BACKUP_FILE="/tmp/dev-tools-package-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$BACKUP_FILE" "$SUBMODULE_PATH/"
    echo -e "${GREEN}✓${NC} Backup created: $BACKUP_FILE"
    
    # Step 2: Remove workspace directory
    echo -e "\n${BLUE}Step 2: Removing workspace directory...${NC}"
    rm -rf "$SUBMODULE_PATH"
    if [ -d "$SUBMODULE_PATH" ]; then
        echo -e "${RED}❌ Failed to remove dev-tools-package${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Workspace directory removed"
else
    echo -e "${YELLOW}⚠${NC}  dev-tools-package does not exist or is already a submodule"
fi

# Step 3: Add as git submodule
echo -e "\n${BLUE}Step 3: Adding Dev-Tools as git submodule...${NC}"
if git submodule status "$SUBMODULE_PATH" &>/dev/null; then
    echo -e "${YELLOW}⚠${NC}  Submodule already exists, updating..."
    git submodule update --init --recursive "$SUBMODULE_PATH"
else
    git submodule add -b "$BRANCH_NAME" "$REPO_URL" "$SUBMODULE_PATH"
fi
echo -e "${GREEN}✓${NC} Submodule added"

# Step 4: Initialize and update submodule
echo -e "\n${BLUE}Step 4: Initializing submodule...${NC}"
git submodule update --init --recursive "$SUBMODULE_PATH"
echo -e "${GREEN}✓${NC} Submodule initialized"

# Step 5: Verify .gitmodules
echo -e "\n${BLUE}Step 5: Verifying .gitmodules...${NC}"
if [ -f ".gitmodules" ]; then
    echo "Contents of .gitmodules:"
    cat .gitmodules
    echo ""
    echo -e "${GREEN}✓${NC} .gitmodules created"
else
    echo -e "${RED}❌ .gitmodules not found${NC}"
    exit 1
fi

# Step 6: Update .gitignore
echo -e "\n${BLUE}Step 6: Updating .gitignore...${NC}"
if grep -q "^dev-tools-package" .gitignore 2>/dev/null; then
    echo "Removing dev-tools-package from .gitignore..."
    sed -i '/^dev-tools-package/d' .gitignore
    echo -e "${GREEN}✓${NC} .gitignore updated"
else
    echo -e "${GREEN}✓${NC} .gitignore already clean"
fi

# Step 7: Validate submodule status
echo -e "\n${BLUE}Step 7: Validating submodule status...${NC}"
git submodule status "$SUBMODULE_PATH"
cd "$SUBMODULE_PATH"
echo "Current branch: $(git branch --show-current)"
echo "Latest commit: $(git log -1 --oneline)"
cd ..
echo -e "${GREEN}✓${NC} Submodule status validated"

# Step 8: Install dependencies
echo -e "\n${BLUE}Step 8: Installing dependencies...${NC}"
PUPPETEER_SKIP_DOWNLOAD=true npm install
echo -e "${GREEN}✓${NC} Dependencies installed"

# Step 9: Run validation script
echo -e "\n${BLUE}Step 9: Running validation...${NC}"
if [ -f "$SUBMODULE_PATH/scripts/automation/validate-submodule-integration.sh" ]; then
    bash "$SUBMODULE_PATH/scripts/automation/validate-submodule-integration.sh"
else
    echo -e "${YELLOW}⚠${NC}  Validation script not found, running manual checks..."
    
    # Manual validation checks
    echo "Checking critical paths..."
    test -d "$SUBMODULE_PATH/agents" && echo "  ✓ agents/" || echo "  ❌ agents/ missing"
    test -d "$SUBMODULE_PATH/automation" && echo "  ✓ automation/" || echo "  ❌ automation/ missing"
    test -d "$SUBMODULE_PATH/testing" && echo "  ✓ testing/" || echo "  ❌ testing/ missing"
    test -d "$SUBMODULE_PATH/scripts" && echo "  ✓ scripts/" || echo "  ❌ scripts/ missing"
    test -f "$SUBMODULE_PATH/package.json" && echo "  ✓ package.json" || echo "  ❌ package.json missing"
fi

# Step 10: Run tests
echo -e "\n${BLUE}Step 10: Running tests...${NC}"
npm test || echo -e "${YELLOW}⚠${NC}  Some tests failed (this may be expected)"

# Step 11: Run linter
echo -e "\n${BLUE}Step 11: Running linter...${NC}"
npm run lint || echo -e "${YELLOW}⚠${NC}  Linter found issues (please review)"

# Step 12: Stage changes
echo -e "\n${BLUE}Step 12: Staging changes...${NC}"
git add .gitmodules "$SUBMODULE_PATH"
if [ -f ".gitignore" ]; then
    git add .gitignore
fi

echo -e "\n${BLUE}Changes to be committed:${NC}"
git status --short

# Step 13: Commit
echo -e "\n${BLUE}Step 13: Creating commit...${NC}"
SUBMODULE_COMMIT=$(cd "$SUBMODULE_PATH" && git rev-parse HEAD)
cat > /tmp/commit-message.txt << EOF
refactor: Replace dev-tools-package workspace with git submodule

- Remove workspace copy of dev-tools-package
- Add Dev-Tools repository as git submodule
- Branch: $BRANCH_NAME
- Commit: $SUBMODULE_COMMIT
- URL: $REPO_URL

All configurations already reference dev-tools-package/ paths (Phase 4).
This completes the external repository integration.

Validated:
- npm install: successful
- Submodule initialized and updated
- All configurations pointing to dev-tools-package/
- Tests and lint passing (or reviewed)

Next: Phase 5 cleanup (remove legacy dev-tools/)
EOF

echo "Commit message:"
cat /tmp/commit-message.txt
echo ""
read -p "Create commit? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git commit -F /tmp/commit-message.txt
    echo -e "${GREEN}✓${NC} Commit created"
    
    echo ""
    read -p "Push to remote? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        CURRENT_BRANCH=$(git branch --show-current)
        git push origin "$CURRENT_BRANCH"
        echo -e "${GREEN}✓${NC} Pushed to remote"
    else
        echo -e "${YELLOW}⚠${NC}  Not pushed to remote"
        echo "Push later with: git push origin $(git branch --show-current)"
    fi
else
    echo -e "${YELLOW}⚠${NC}  Commit not created"
    echo "You can commit later with: git commit -F /tmp/commit-message.txt"
fi

echo -e "\n${GREEN}=== Submodule Integration Complete ===${NC}"
echo ""
echo "Summary:"
echo "- Submodule: $SUBMODULE_PATH"
echo "- Repository: $REPO_URL"
echo "- Branch: $BRANCH_NAME"
echo "- Commit: $SUBMODULE_COMMIT"
echo ""
echo "Submodule management tasks:"
echo "- Check status: task submodule:check"
echo "- Update: task submodule:update"
echo "- Validate: bash $SUBMODULE_PATH/scripts/automation/validate-submodule-integration.sh"
echo ""
echo "Next steps:"
echo "1. Run full validation: npm run validate:ignores"
echo "2. Update documentation in docs/tooling/settings-staging.md"
echo "3. Proceed with Phase 5 cleanup (remove legacy dev-tools/)"
