# Dev-Tools Submodule Integration - Automation Scripts

This directory contains automated scripts for publishing the Dev-Tools package to GitHub and integrating it as a git submodule in ProspectPro.

## Overview

The migration from workspace directory to git submodule is a two-phase process:

1. **External Publication** - Publish dev-tools-package to https://github.com/Alextorelli/Dev-Tools
2. **Submodule Integration** - Replace workspace directory with git submodule in ProspectPro

## Prerequisites

Before running these scripts, ensure:

- [ ] Phase 4 complete (all configurations updated to use `dev-tools-package/` paths)
- [ ] All tests passing in ProspectPro (5/5, 100%)
- [ ] Lint clean (0 errors)
- [ ] TypeScript compilation validated
- [ ] GitHub credentials configured (`gh` CLI or git credentials)
- [ ] Write access to https://github.com/Alextorelli/Dev-Tools

## Script 1: publish-to-github.sh

**Purpose:** Automate the publication of dev-tools-package to the external Dev-Tools GitHub repository.

**Location:** `dev-tools-package/scripts/automation/publish-to-github.sh`

**What it does:**

1. Clones or updates the Dev-Tools repository at `/tmp/Dev-Tools`
2. Checks out the `prospect-pro-tools` branch
3. Copies all dev-tools-package contents (excluding node_modules, dist, logs)
4. Creates `package.json`, `tsconfig.json`, `LICENSE`, `.gitignore`
5. Creates `EXTRACTION_MANIFEST.md` with complete documentation
6. Copies provenance docs (`REPO_RESTRUCTURE_PLAN.md`, `coverage.md`)
7. Creates `CHANGELOG.md` for version tracking
8. Creates GitHub Actions CI workflow (`.github/workflows/ci.yml`)
9. Commits all changes with detailed commit message
10. Pushes to remote (with confirmation prompts)
11. Creates and pushes `v1.0.0` tag (with confirmation prompts)

**Usage:**

```bash
# From ProspectPro repository root
cd /home/runner/work/ProspectPro/ProspectPro

# Run the publication script
bash dev-tools-package/scripts/automation/publish-to-github.sh
```

**Interactive Prompts:**

- Push to remote? (y/n)
- Push tag to remote? (y/n)

**Output:**

- Repository: https://github.com/Alextorelli/Dev-Tools
- Branch: prospect-pro-tools
- Tag: v1.0.0
- Working directory: /tmp/Dev-Tools

**Verification Steps:**

After running the script:

1. Visit https://github.com/Alextorelli/Dev-Tools
2. Confirm `prospect-pro-tools` branch exists
3. Confirm `v1.0.0` tag exists
4. Check GitHub Actions CI is running/passing
5. Review files and directory structure

## Script 2: integrate-submodule.sh

**Purpose:** Replace the workspace copy of dev-tools-package with a git submodule pointing to the published Dev-Tools repository.

**Location:** `dev-tools-package/scripts/automation/integrate-submodule.sh`

**Prerequisites:**

- Dev-Tools repository published (Script 1 completed)
- `prospect-pro-tools` branch exists on GitHub
- `v1.0.0` tag created
- GitHub Actions CI passing (optional but recommended)

**What it does:**

1. Verifies we're in ProspectPro repository root
2. Creates backup of current dev-tools-package (`/tmp/dev-tools-package-backup-*.tar.gz`)
3. Removes workspace directory (`rm -rf dev-tools-package`)
4. Adds Dev-Tools as git submodule
5. Initializes and updates submodule
6. Verifies `.gitmodules` created
7. Updates `.gitignore` (removes dev-tools-package entries)
8. Validates submodule status
9. Installs dependencies (`npm install`)
10. Runs validation script
11. Runs tests and linter
12. Stages changes (`.gitmodules`, submodule pointer, `.gitignore`)
13. Creates commit with detailed message
14. Pushes to remote (with confirmation prompts)

**Usage:**

```bash
# From ProspectPro repository root
cd /home/runner/work/ProspectPro/ProspectPro

# Run the integration script
bash dev-tools-package/scripts/automation/integrate-submodule.sh
```

**Interactive Prompts:**

- Continue with backup and removal? (y/n)
- Create commit? (y/n)
- Push to remote? (y/n)

**Output:**

- Backup file: `/tmp/dev-tools-package-backup-YYYYMMDD-HHMMSS.tar.gz`
- Submodule path: `dev-tools-package/`
- Submodule URL: https://github.com/Alextorelli/Dev-Tools.git
- Submodule branch: prospect-pro-tools

**Verification Steps:**

After running the script:

1. Check `.gitmodules` exists and contains correct configuration
2. Verify `git submodule status` shows the submodule
3. Run `npm install` and ensure it completes successfully
4. Run `npm test` and ensure tests pass
5. Run `npm run lint` and ensure no errors
6. Check `dev-tools-package/.git` is a file (not a directory) - indicates submodule

## Complete Workflow

### Step 1: Publish to GitHub (External)

```bash
cd /home/runner/work/ProspectPro/ProspectPro
bash dev-tools-package/scripts/automation/publish-to-github.sh
```

**Confirm:**
- Answer 'y' to push to remote
- Answer 'y' to push tag to remote

**Verify on GitHub:**
- Visit https://github.com/Alextorelli/Dev-Tools
- Check `prospect-pro-tools` branch exists
- Check `v1.0.0` tag exists
- Confirm files are present (README.md, package.json, agents/, etc.)

### Step 2: Integrate as Submodule (ProspectPro)

```bash
cd /home/runner/work/ProspectPro/ProspectPro
bash dev-tools-package/scripts/automation/integrate-submodule.sh
```

**Confirm:**
- Answer 'y' to continue with backup and removal
- Answer 'y' to create commit
- Answer 'y' to push to remote

**Verify:**
```bash
# Check submodule status
git submodule status

# Verify configuration
cat .gitmodules

# Test integration
PUPPETEER_SKIP_DOWNLOAD=true npm install
npm test
npm run lint

# Validate submodule
bash dev-tools-package/scripts/automation/validate-submodule-integration.sh
```

### Step 3: Update Documentation

```bash
# Update settings-staging.md
cat >> docs/tooling/settings-staging.md << 'EOF'

## Phase 4 to 5 Transition - Git Submodule Integration ✅

### $(date +%Y-%m-%d) - Submodule Swap Complete

**Change:** Replaced dev-tools-package workspace copy with git submodule

**Details:**
- Removed workspace copy: `rm -rf dev-tools-package`
- Added git submodule:
  - Repository: https://github.com/Alextorelli/Dev-Tools.git
  - Branch: prospect-pro-tools
  - Initial commit: $(cd dev-tools-package && git rev-parse HEAD)

**Validation:**
- ✅ npm install successful
- ✅ Tests passing
- ✅ Lint clean
- ✅ .gitmodules created and committed

**Next Steps:**
- Monitor submodule with `task submodule:check`
- Proceed with Phase 5 cleanup (remove legacy dev-tools/)
EOF

git add docs/tooling/settings-staging.md
git commit -m "docs: Document submodule integration in settings-staging.md"
git push
```

## Submodule Management Tasks

After integration, use these commands to manage the submodule:

### Check Submodule Status

```bash
# Check if submodule is up to date
task submodule:check

# Or manually
cd dev-tools-package
git fetch origin prospect-pro-tools
git status
cd ..
```

### Update Submodule

```bash
# Update to latest remote commit
task submodule:update

# Or manually
git submodule update --remote --merge dev-tools-package
git add dev-tools-package
git commit -m "chore: Update dev-tools-package submodule"
git push
```

### Initialize Submodule (After Clone)

```bash
# Initialize submodule in a fresh clone
git submodule update --init --recursive
```

### Validate Submodule Integration

```bash
# Run comprehensive validation
bash dev-tools-package/scripts/automation/validate-submodule-integration.sh
```

## Troubleshooting

### Script 1: publish-to-github.sh

**Issue:** Git asks for credentials

**Solution:**
- Configure GitHub credentials: `gh auth login`
- Or set up git credential helper: `git config --global credential.helper store`

**Issue:** Remote already has commits

**Solution:**
- Pull first: `cd /tmp/Dev-Tools && git pull origin prospect-pro-tools`
- Or force push (⚠️ caution): `git push -f origin prospect-pro-tools`

**Issue:** Provenance files not found

**Solution:**
- The script will skip missing files with a warning
- Verify files exist:
  - `dev-tools/workspace/context/session_store/REPO_RESTRUCTURE_PLAN.md`
  - `dev-tools/workspace/context/session_store/coverage.md`

### Script 2: integrate-submodule.sh

**Issue:** Submodule already exists error

**Solution:**
```bash
# Remove existing submodule
git submodule deinit -f dev-tools-package
git rm -f dev-tools-package
rm -rf .git/modules/dev-tools-package
# Then re-run the script
```

**Issue:** npm install fails

**Solution:**
```bash
# Install submodule dependencies first
cd dev-tools-package
npm install
cd ..
PUPPETEER_SKIP_DOWNLOAD=true npm install
```

**Issue:** Tests fail after submodule integration

**Solution:**
- Check that all paths reference `dev-tools-package/` (not `dev-tools/`)
- Search for old imports: `rg "from ['\"].*dev-tools/" --type ts`
- Run validation: `bash dev-tools-package/scripts/automation/validate-submodule-integration.sh`

**Issue:** Submodule shows as modified

**Solution:**
```bash
# This is normal if the submodule has uncommitted changes or is on a different commit
# To sync to the expected commit:
cd dev-tools-package
git checkout prospect-pro-tools
git pull origin prospect-pro-tools
cd ..
git add dev-tools-package
git commit -m "chore: Sync dev-tools-package submodule to latest"
```

## Safety Features

Both scripts include safety features:

- **Backup creation** - Script 2 creates a backup before removing workspace directory
- **Confirmation prompts** - Scripts ask before pushing to remote
- **Validation checks** - Scripts run validation before proceeding
- **Detailed output** - Scripts show exactly what they're doing
- **Error handling** - Scripts exit on errors with clear messages

## Rollback Procedure

If something goes wrong, you can rollback:

### Rollback Script 1 (GitHub Publication)

```bash
# If you haven't pushed yet, just delete the /tmp/Dev-Tools directory
rm -rf /tmp/Dev-Tools

# If you've pushed, delete the branch and tag on GitHub
cd /tmp/Dev-Tools
git push origin --delete prospect-pro-tools
git push origin --delete v1.0.0

# Or use GitHub UI to delete branch and tag
```

### Rollback Script 2 (Submodule Integration)

```bash
# Restore from backup
cd /home/runner/work/ProspectPro/ProspectPro

# Remove submodule
git submodule deinit -f dev-tools-package
git rm -f dev-tools-package
rm -rf .git/modules/dev-tools-package

# Restore from backup
tar -xzf /tmp/dev-tools-package-backup-*.tar.gz

# Commit restoration
git add dev-tools-package .gitmodules
git commit -m "revert: Restore dev-tools-package workspace copy"
git push
```

## Support

For issues or questions:

1. Review this README
2. Check the migration guide: `DEV_TOOLS_MIGRATION_GUIDE.md`
3. Review the quick reference: `DEV_TOOLS_MIGRATION_QUICKREF.md`
4. Check validation output: `bash dev-tools-package/scripts/automation/validate-submodule-integration.sh`
5. Check phase plan: `dev-tools/workspace/context/session_store/REPO_RESTRUCTURE_PLAN.md`

## Related Documentation

- [DEV_TOOLS_MIGRATION_GUIDE.md](../../../DEV_TOOLS_MIGRATION_GUIDE.md) - Complete migration guide
- [DEV_TOOLS_MIGRATION_QUICKREF.md](../../../DEV_TOOLS_MIGRATION_QUICKREF.md) - Quick reference
- [REPO_RESTRUCTURE_PLAN.md](../../../dev-tools/workspace/context/session_store/REPO_RESTRUCTURE_PLAN.md) - Phase-by-phase plan
- [validate-submodule-integration.sh](./validate-submodule-integration.sh) - Validation script

---

**Status:** Ready for use ✅  
**Phase:** 4 Complete → 5 Ready  
**Date:** 2025-11-01
