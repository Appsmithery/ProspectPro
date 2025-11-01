#!/usr/bin/env bash
# validate-submodule-integration.sh
# Validates that ProspectPro's dev-tools-package submodule integration is healthy
# Usage: bash dev-tools-package/scripts/automation/validate-submodule-integration.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "======================================"
echo "Dev-Tools Submodule Integration Check"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_passed=0
check_failed=0

# Helper function to run checks
run_check() {
    local check_name="$1"
    local check_command="$2"
    
    echo -n "Checking $check_name... "
    
    if eval "$check_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((check_passed++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((check_failed++))
        return 1
    fi
}

run_check_output() {
    local check_name="$1"
    local check_command="$2"
    
    echo "Checking $check_name..."
    
    if eval "$check_command"; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((check_passed++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((check_failed++))
        return 1
    fi
}

cd "$REPO_ROOT"

echo "Repository Root: $REPO_ROOT"
echo ""

# 1. Check if dev-tools-package exists
echo "=== Basic Checks ==="
run_check "dev-tools-package directory exists" "test -d dev-tools-package"

# 2. Check if it's a git submodule
run_check ".gitmodules file exists" "test -f .gitmodules"

if [ -f .gitmodules ]; then
    run_check_output "Submodule configuration" "grep -q 'dev-tools-package' .gitmodules"
fi

# 3. Check submodule status
echo ""
echo "=== Submodule Status ==="
run_check_output "Git submodule status" "git submodule status dev-tools-package"

# 4. Check if submodule is initialized
run_check "Submodule initialized" "test -f dev-tools-package/.git"

# 5. Check submodule branch
if [ -f dev-tools-package/.git ]; then
    echo ""
    echo "=== Submodule Branch Info ==="
    cd dev-tools-package
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
    CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    echo "Current branch: $CURRENT_BRANCH"
    echo "Current commit: $CURRENT_COMMIT"
    
    if [ "$CURRENT_BRANCH" = "prospect-pro-tools" ]; then
        echo -e "${GREEN}✓ On correct branch (prospect-pro-tools)${NC}"
        ((check_passed++))
    else
        echo -e "${YELLOW}⚠ Not on prospect-pro-tools branch (current: $CURRENT_BRANCH)${NC}"
        ((check_failed++))
    fi
    
    cd "$REPO_ROOT"
fi

# 6. Check critical directory structure
echo ""
echo "=== Directory Structure ==="
run_check "agents/ directory exists" "test -d dev-tools-package/agents"
run_check "automation/ directory exists" "test -d dev-tools-package/automation"
run_check "scripts/ directory exists" "test -d dev-tools-package/scripts"
run_check "testing/ directory exists" "test -d dev-tools-package/testing"

# 7. Check agent profiles
echo ""
echo "=== Agent Profiles ==="
for agent in _development-workflow _observability _production-ops _system-architect; do
    run_check "Agent profile: $agent" "test -d dev-tools-package/agents/$agent"
done

# 8. Check MCP servers
echo ""
echo "=== MCP Servers ==="
run_check "utility MCP server" "test -d dev-tools-package/agents/mcp-servers/utility"
run_check "client-service-layer" "test -d dev-tools-package/agents/client-service-layer"

# 9. Check critical scripts
echo ""
echo "=== Critical Scripts ==="
run_check "repo_scan.sh" "test -f dev-tools-package/automation/ci-cd/repo_scan.sh"
run_check "migration-dry-run.sh" "test -f dev-tools-package/scripts/automation/migration-dry-run.sh"

# 10. Check workspace configuration
echo ""
echo "=== Workspace Configuration ==="
if [ -f package.json ]; then
    run_check "package.json references dev-tools-package" "grep -q 'dev-tools-package' package.json"
    
    # Check workspace entries
    if grep -q '"workspaces"' package.json; then
        WORKSPACE_COUNT=$(grep -A 5 '"workspaces"' package.json | grep -c 'dev-tools-package' || true)
        if [ "$WORKSPACE_COUNT" -gt 0 ]; then
            echo -e "${GREEN}✓ Found $WORKSPACE_COUNT workspace entries for dev-tools-package${NC}"
            ((check_passed++))
        else
            echo -e "${RED}✗ No workspace entries found for dev-tools-package${NC}"
            ((check_failed++))
        fi
    fi
fi

# 11. Check Taskfile configuration
echo ""
echo "=== Taskfile Configuration ==="
if [ -f Taskfile.yml ]; then
    run_check "Taskfile.yml references dev-tools-package" "grep -q 'dev-tools-package' Taskfile.yml"
fi

# 12. Check VS Code MCP configuration
echo ""
echo "=== VS Code Configuration ==="
if [ -f .vscode/mcp_config.json ]; then
    run_check "mcp_config.json references dev-tools-package" "grep -q 'dev-tools-package' .vscode/mcp_config.json"
fi

# 13. Check for legacy dev-tools/ references
echo ""
echo "=== Legacy References Check ==="
echo "Searching for legacy dev-tools/ imports..."

# Search in key directories (excluding the submodule itself)
LEGACY_IMPORTS=$(rg "from ['\"].*dev-tools/" --type ts --type js app/ integration/ config/ tests/ 2>/dev/null | grep -v "dev-tools-package" | wc -l || echo "0")

if [ "$LEGACY_IMPORTS" -eq 0 ]; then
    echo -e "${GREEN}✓ No legacy dev-tools/ imports found${NC}"
    ((check_passed++))
else
    echo -e "${YELLOW}⚠ Found $LEGACY_IMPORTS legacy dev-tools/ imports${NC}"
    echo "Run: rg \"from ['\\\"].*dev-tools/\" --type ts --type js app/ integration/ config/ tests/"
    ((check_failed++))
fi

# 14. Check if old dev-tools/ directory still exists
if [ -d dev-tools ]; then
    echo -e "${YELLOW}⚠ Legacy dev-tools/ directory still exists (Phase 5 not complete)${NC}"
    ((check_failed++))
else
    echo -e "${GREEN}✓ Legacy dev-tools/ directory removed (Phase 5 complete)${NC}"
    ((check_passed++))
fi

# 15. Check submodule remote URL
echo ""
echo "=== Remote Configuration ==="
cd dev-tools-package 2>/dev/null && {
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "unknown")
    echo "Remote URL: $REMOTE_URL"
    
    if [[ "$REMOTE_URL" == *"Alextorelli/Dev-Tools"* ]] || [[ "$REMOTE_URL" == *"Dev-Tools.git"* ]]; then
        echo -e "${GREEN}✓ Correct remote URL${NC}"
        ((check_passed++))
    else
        echo -e "${RED}✗ Unexpected remote URL${NC}"
        ((check_failed++))
    fi
    
    cd "$REPO_ROOT"
} || {
    echo -e "${RED}✗ Could not check remote URL${NC}"
    ((check_failed++))
}

# Summary
echo ""
echo "======================================"
echo "Validation Summary"
echo "======================================"
echo -e "Passed: ${GREEN}$check_passed${NC}"
echo -e "Failed: ${RED}$check_failed${NC}"
echo ""

if [ $check_failed -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Submodule integration is healthy.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Review the output above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "1. Initialize submodule: git submodule update --init --recursive"
    echo "2. Update submodule: git submodule update --remote dev-tools-package"
    echo "3. Check submodule branch: cd dev-tools-package && git checkout prospect-pro-tools"
    echo "4. Remove legacy imports: Update import paths from dev-tools/ to dev-tools-package/"
    exit 1
fi
