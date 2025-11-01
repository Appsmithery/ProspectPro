#!/usr/bin/env bash
# validate-submodule-migration.sh
# Validates the dev-tools-package submodule migration
# Usage: bash dev-tools-package/scripts/automation/validate-submodule-migration.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "======================================"
echo "Dev-Tools Submodule Migration Validator"
echo "======================================"
echo ""

cd "$REPO_ROOT"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

VALIDATION_PASSED=true

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    VALIDATION_PASSED=false
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

info() {
    echo "ℹ $1"
}

# Check if using submodule or workspace
if [ -f .gitmodules ]; then
    MODE="submodule"
    info "Mode: Git Submodule"
else
    MODE="workspace"
    info "Mode: NPM Workspace (local copy)"
fi

echo ""
echo "1. Checking dev-tools-package directory..."
if [ -d dev-tools-package ]; then
    pass "dev-tools-package directory exists"
else
    fail "dev-tools-package directory not found"
    echo ""
    echo "Migration cannot proceed without dev-tools-package"
    exit 1
fi

echo ""
echo "2. Checking submodule configuration..."
if [ "$MODE" = "submodule" ]; then
    if git submodule status dev-tools-package | grep -q '^-'; then
        fail "Submodule is not initialized"
        info "Run: git submodule update --init --recursive"
    elif git submodule status dev-tools-package | grep -q '^+'; then
        warn "Submodule commit differs from repository"
        info "Run: git add dev-tools-package && git commit"
    else
        pass "Submodule is properly initialized and current"
    fi
    
    # Check .gitmodules
    if grep -q "dev-tools-package" .gitmodules; then
        pass ".gitmodules contains dev-tools-package entry"
    else
        fail ".gitmodules missing dev-tools-package entry"
    fi
else
    pass "Using workspace mode (pre-submodule)"
fi

echo ""
echo "3. Checking directory structure..."
REQUIRED_DIRS=(
    "dev-tools-package/agents"
    "dev-tools-package/automation"
    "dev-tools-package/scripts"
    "dev-tools-package/testing"
    "dev-tools-package/workspace"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        pass "$dir exists"
    else
        fail "$dir not found"
    fi
done

echo ""
echo "4. Checking critical files..."
CRITICAL_FILES=(
    "dev-tools-package/README.md"
    "dev-tools-package/agents/mcp-servers/utility/package.json"
    "dev-tools-package/scripts/automation/migration-dry-run.sh"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "$file exists"
    else
        fail "$file not found"
    fi
done

echo ""
echo "5. Checking package.json configuration..."
if grep -q "dev-tools-package/agents/mcp-servers/\*" package.json; then
    pass "Workspace references dev-tools-package"
else
    fail "package.json missing dev-tools-package workspace entries"
fi

echo ""
echo "6. Checking MCP configuration..."
if [ -f .vscode/mcp_config.json ]; then
    if grep -q "dev-tools-package/agents/mcp-servers" .vscode/mcp_config.json; then
        pass "MCP config references dev-tools-package paths"
    else
        fail "MCP config missing dev-tools-package references"
    fi
else
    warn ".vscode/mcp_config.json not found"
fi

echo ""
echo "7. Checking Taskfile configuration..."
if [ -f Taskfile.yml ]; then
    if grep -q "dev-tools-package/agents" Taskfile.yml; then
        pass "Taskfile references dev-tools-package paths"
    else
        fail "Taskfile missing dev-tools-package references"
    fi
    
    # Check for submodule tasks
    if grep -q "submodule:check" Taskfile.yml; then
        pass "Taskfile includes submodule:check task"
    else
        warn "Taskfile missing submodule:check task (add if using submodule)"
    fi
else
    warn "Taskfile.yml not found"
fi

echo ""
echo "8. Checking GitHub workflows..."
WORKFLOW_FILES=(
    ".github/workflows/mcp-agent-validation.yml"
)

for workflow in "${WORKFLOW_FILES[@]}"; do
    if [ -f "$workflow" ]; then
        if grep -q "dev-tools-package" "$workflow"; then
            pass "$workflow references dev-tools-package"
        else
            fail "$workflow missing dev-tools-package references"
        fi
        
        if [ "$MODE" = "submodule" ]; then
            if grep -q "submodules: recursive\|submodule update" "$workflow"; then
                pass "$workflow includes submodule initialization"
            else
                warn "$workflow missing submodule init (required for CI)"
            fi
        fi
    else
        info "$workflow not found (may not exist yet)"
    fi
done

echo ""
echo "9. Running npm validation..."
if command -v npm &> /dev/null; then
    info "Checking npm install..."
    if npm install --dry-run &> /dev/null; then
        pass "npm install validation passed"
    else
        fail "npm install validation failed"
        info "Run: npm install"
    fi
else
    warn "npm not found, skipping npm validation"
fi

echo ""
echo "10. Checking for legacy dev-tools references..."
LEGACY_CHECKS=(
    "package.json:\"dev-tools/agents\""
    "Taskfile.yml:dev-tools/agents"
    ".vscode/mcp_config.json:dev-tools/agents"
)

LEGACY_FOUND=false
for check in "${LEGACY_CHECKS[@]}"; do
    file="${check%:*}"
    pattern="${check#*:}"
    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        warn "Legacy reference found in $file: $pattern"
        LEGACY_FOUND=true
    fi
done

if [ "$LEGACY_FOUND" = false ]; then
    pass "No legacy dev-tools references found"
fi

echo ""
echo "======================================"
echo "Validation Summary"
echo "======================================"

if [ "$VALIDATION_PASSED" = true ]; then
    echo -e "${GREEN}✓ All validation checks passed${NC}"
    echo ""
    echo "Next steps:"
    if [ "$MODE" = "workspace" ]; then
        echo "1. Wait for Dev-Tools repository to be published"
        echo "2. Follow migration steps in docs/tooling/settings-staging.md"
        echo "3. Run this script again after migration to verify"
    else
        echo "1. Run: npm install"
        echo "2. Run: npm test"
        echo "3. Run: npm run lint"
        echo "4. Run: task submodule:check"
    fi
    exit 0
else
    echo -e "${RED}✗ Some validation checks failed${NC}"
    echo ""
    echo "Please address the failures above before proceeding with migration."
    exit 1
fi
