#!/usr/bin/env bash
set -euo pipefail

# analyze-dependencies.sh
# Analyzes package.json dependencies across dev-tools and app domains
# to identify shared dependencies and extraction requirements for Phase 2.

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
REPORT_DIR="$ROOT_DIR/dev-tools/reports"
mkdir -p "$REPORT_DIR"

echo "=== Analyzing Dependencies ==="
echo ""

# Create temporary files for comparison
DEV_TOOLS_DEPS="/tmp/dev-tools-deps.txt"
APP_DEPS="/tmp/app-deps.txt"
REPORT_FILE="$REPORT_DIR/dependency-analysis.txt"

> "$DEV_TOOLS_DEPS"
> "$APP_DEPS"

echo "1. Checking dev-tools package.json dependencies..."

# Function to extract dependencies from package.json
extract_deps() {
  local pkg_file="$1"
  local target_file="$2"
  
  if [ -f "$pkg_file" ]; then
    # Extract both dependencies and devDependencies
    python3 -c "
import json
import sys

try:
    with open('$pkg_file') as f:
        data = json.load(f)
    
    deps = set()
    for key in ['dependencies', 'devDependencies', 'peerDependencies']:
        if key in data:
            deps.update(data[key].keys())
    
    for dep in sorted(deps):
        print(dep)
except Exception as e:
    print(f'Error parsing $pkg_file: {e}', file=sys.stderr)
" >> "$target_file"
  fi
}

# Check all dev-tools package.json files
find "$ROOT_DIR/dev-tools" -name package.json -not -path "*/node_modules/*" | while read -r pkg; do
  pkg_dir=$(dirname "$pkg")
  pkg_name=$(basename "$pkg_dir")
  echo "   - Scanning $pkg_name..."
  extract_deps "$pkg" "$DEV_TOOLS_DEPS"
done

echo ""
echo "2. Checking app package.json dependencies..."

# Check app/frontend dependencies
if [ -f "$ROOT_DIR/app/frontend/package.json" ]; then
  echo "   - Scanning app/frontend..."
  extract_deps "$ROOT_DIR/app/frontend/package.json" "$APP_DEPS"
fi

# Check root package.json
if [ -f "$ROOT_DIR/package.json" ]; then
  echo "   - Scanning root package.json..."
  extract_deps "$ROOT_DIR/package.json" "$APP_DEPS"
fi

echo ""
echo "3. Analyzing dependency overlaps..."

# Sort and deduplicate
sort -u "$DEV_TOOLS_DEPS" -o "$DEV_TOOLS_DEPS"
sort -u "$APP_DEPS" -o "$APP_DEPS"

# Generate report
{
  echo "# Dependency Analysis Report"
  echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo ""
  echo "## Summary"
  echo ""
  echo "- **Dev-tools dependencies**: $(wc -l < "$DEV_TOOLS_DEPS") unique packages"
  echo "- **App dependencies**: $(wc -l < "$APP_DEPS") unique packages"
  echo ""
  
  # Find shared dependencies
  SHARED_DEPS=$(comm -12 "$DEV_TOOLS_DEPS" "$APP_DEPS")
  SHARED_COUNT=$(echo "$SHARED_DEPS" | grep -c . || echo 0)
  
  echo "- **Shared dependencies**: $SHARED_COUNT packages"
  echo ""
  
  if [ "$SHARED_COUNT" -gt 0 ]; then
    echo "## Shared Dependencies"
    echo ""
    echo "These packages are used by both dev-tools and app domains:"
    echo '```'
    echo "$SHARED_DEPS"
    echo '```'
    echo ""
  fi
  
  # Dev-tools only dependencies
  DEV_ONLY=$(comm -23 "$DEV_TOOLS_DEPS" "$APP_DEPS")
  DEV_ONLY_COUNT=$(echo "$DEV_ONLY" | grep -c . || echo 0)
  
  if [ "$DEV_ONLY_COUNT" -gt 0 ]; then
    echo "## Dev-Tools Specific Dependencies"
    echo ""
    echo "These packages are only used by dev-tools ($DEV_ONLY_COUNT packages):"
    echo '```'
    echo "$DEV_ONLY"
    echo '```'
    echo ""
  fi
  
  # App only dependencies
  APP_ONLY=$(comm -13 "$DEV_TOOLS_DEPS" "$APP_DEPS")
  APP_ONLY_COUNT=$(echo "$APP_ONLY" | grep -c . || echo 0)
  
  if [ "$APP_ONLY_COUNT" -gt 0 ]; then
    echo "## App Specific Dependencies"
    echo ""
    echo "These packages are only used by app domain ($APP_ONLY_COUNT packages):"
    echo '```'
    echo "$APP_ONLY"
    echo '```'
    echo ""
  fi
  
  echo "## Extraction Implications"
  echo ""
  echo "### For Dev-Tools Repository"
  echo "- Move dev-tools specific dependencies to new repo's package.json"
  echo "- Shared dependencies should be evaluated case-by-case"
  echo "- Consider peer dependencies for packages used by both domains"
  echo ""
  
  echo "### For ProspectPro Integration"
  echo "- Shared dependencies may indicate tight coupling"
  echo "- Review if dev-tools can reduce app-specific dependencies"
  echo "- Document rationale for any retained cross-domain dependencies"
  echo ""
  
} > "$REPORT_FILE"

# Clean up temp files
rm -f "$DEV_TOOLS_DEPS" "$APP_DEPS"

echo ""
echo "✅ Analysis complete!"
echo "   Report saved to: $REPORT_FILE"
echo ""
cat "$REPORT_FILE"
