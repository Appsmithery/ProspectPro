# 🚀 Dev-Tools Publication - Execution Guide

This guide provides the exact commands to publish the Dev-Tools package to GitHub and integrate it as a submodule in ProspectPro.

## 📋 Quick Start

### Step 1: Publish Dev-Tools to GitHub

```bash
cd /home/runner/work/ProspectPro/ProspectPro
bash dev-tools-package/scripts/automation/publish-to-github.sh
```

This script will:
- Clone https://github.com/Alextorelli/Dev-Tools to `/tmp/Dev-Tools`
- Copy all dev-tools-package contents
- Create package.json, tsconfig.json, LICENSE, .gitignore
- Create EXTRACTION_MANIFEST.md, CHANGELOG.md, GitHub Actions CI
- Commit with detailed message
- Ask for confirmation before pushing
- Create and push v1.0.0 tag

**Prompts you'll see:**
- `Push to remote? (y/n)` - Answer `y`
- `Push tag to remote? (y/n)` - Answer `y`

### Step 2: Verify on GitHub

Visit https://github.com/Alextorelli/Dev-Tools and confirm:
- ✅ `prospect-pro-tools` branch exists
- ✅ `v1.0.0` tag exists
- ✅ Files are present (README.md, package.json, agents/, etc.)
- ✅ GitHub Actions CI is running/passing (optional)

### Step 3: Integrate as Submodule

```bash
cd /home/runner/work/ProspectPro/ProspectPro
bash dev-tools-package/scripts/automation/integrate-submodule.sh
```

This script will:
- Create backup at `/tmp/dev-tools-package-backup-*.tar.gz`
- Remove workspace directory
- Add Dev-Tools as git submodule
- Initialize and update submodule
- Run validation, tests, and lint
- Create commit with detailed message
- Ask for confirmation before pushing

**Prompts you'll see:**
- `Continue? (y/n)` - Answer `y` to proceed with backup and removal
- `Create commit? (y/n)` - Answer `y` to commit the submodule
- `Push to remote? (y/n)` - Answer `y` to push to GitHub

### Step 4: Validate Integration

```bash
# Check submodule status
git submodule status

# Verify configuration
cat .gitmodules

# Test integration
PUPPETEER_SKIP_DOWNLOAD=true npm install
npm test
npm run lint

# Run comprehensive validation
bash dev-tools-package/scripts/automation/validate-submodule-integration.sh
```

## 📚 Detailed Documentation

For complete details, troubleshooting, and rollback procedures, see:
- [README-SUBMODULE-INTEGRATION.md](dev-tools-package/scripts/automation/README-SUBMODULE-INTEGRATION.md)
- [DEV_TOOLS_MIGRATION_GUIDE.md](DEV_TOOLS_MIGRATION_GUIDE.md)
- [DEV_TOOLS_MIGRATION_QUICKREF.md](DEV_TOOLS_MIGRATION_QUICKREF.md)

## ⚡ One-Line Execution

If you trust the scripts and want to run both steps without manual verification:

```bash
# Publish and integrate in one go (not recommended for first time)
bash dev-tools-package/scripts/automation/publish-to-github.sh && \
bash dev-tools-package/scripts/automation/integrate-submodule.sh
```

⚠️ **Warning:** This will run both scripts back-to-back without GitHub verification between them.

## 🔄 Submodule Management (After Integration)

After successful integration, use these commands to manage the submodule:

```bash
# Check if submodule is up to date
task submodule:check

# Update to latest remote commit
task submodule:update

# Validate integration
task submodule:validate

# Initialize after fresh clone
task submodule:init
```

## 🆘 Troubleshooting

### Git asks for credentials during publish

**Solution 1:** Use GitHub CLI
```bash
gh auth login
```

**Solution 2:** Configure git credentials
```bash
git config --global credential.helper store
```

### Submodule integration fails

**Rollback:**
```bash
# Remove submodule
git submodule deinit -f dev-tools-package
git rm -f dev-tools-package
rm -rf .git/modules/dev-tools-package

# Restore from backup
tar -xzf /tmp/dev-tools-package-backup-*.tar.gz

# Commit restoration
git add dev-tools-package .gitmodules
git commit -m "revert: Restore dev-tools-package workspace copy"
```

### npm install fails after submodule integration

**Solution:**
```bash
cd dev-tools-package
npm install
cd ..
PUPPETEER_SKIP_DOWNLOAD=true npm install
```

## ✅ Success Criteria

Before considering the migration complete:

- [ ] Dev-Tools published to GitHub with prospect-pro-tools branch
- [ ] v1.0.0 tag exists on GitHub
- [ ] .gitmodules file created in ProspectPro
- [ ] `git submodule status` shows dev-tools-package
- [ ] npm install completes successfully
- [ ] All tests pass (5/5)
- [ ] Lint clean (0 errors)
- [ ] validate-submodule-integration.sh passes all checks

## 🎯 What Happens Next?

After successful submodule integration:

1. **Phase 5 Cleanup** - Remove legacy `dev-tools/` directory
2. **Documentation Update** - Update `docs/tooling/settings-staging.md`
3. **Final Validation** - Run full CI/CD test suite
4. **Phase 6** - Complete final documentation and provenance

---

**Ready to execute!** 🚀

Start with Step 1 above and follow the prompts.
