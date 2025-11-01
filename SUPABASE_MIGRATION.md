# Supabase Directory Migration

## Overview
All Supabase assets have been consolidated under `app/backend/` to maintain clear separation between production app code and development tools, while eliminating confusing symlinks.

## Previous Structure
```
/
├── supabase/ (symlink to app/backend)
├── app/
│   └── backend/ (actual Supabase files)
└── integration/platform/supabase/ (additional scripts and tests)
```

## New Structure
```
/
└── app/
    └── backend/
        ├── config.toml
        ├── functions/
        ├── migrations/
        ├── schema/
        ├── db/
        ├── scripts/           # Merged from integration/platform/supabase/scripts/
        ├── tests/             # Merged from integration/platform/supabase/tests/
        ├── supabase.js
        ├── supabase-ca-2021.crt
        └── package-supabase.json
```

## What Changed

### Directory Changes
1. **Removed** root-level `supabase/` symlink
2. **Merged** `integration/platform/supabase/scripts/` into `app/backend/scripts/`
3. **Merged** `integration/platform/supabase/tests/` into `app/backend/tests/`
4. **Copied** support files (supabase.js, supabase-ca-2021.crt, package-supabase.json) to `app/backend/`

### Script Updates
All references updated from `cd supabase` to `cd app/backend`:
- `package.json` - 30+ npm scripts updated
- `.vscode/tasks.json` - 5 tasks updated
- `integration/monitoring/observability/supabase-pull-logs.sh`
- `integration/monitoring/diagnostics/diagnose-campaign-failure.sh`
- `integration/monitoring/diagnostics/deployment-validation-workflow.sh`
- `integration/monitoring/diagnostics/edge-function-diagnostics.sh`
- `integration/infrastructure/scripts/inject-api-keys.sh`
- `dev-tools/scripts/setup/.codespaces-init.sh`

### Path Changes
- **Old**: `cd supabase && source ../scripts/operations/ensure-supabase-cli-session.sh`
- **New**: `cd app/backend && source ../../dev-tools/scripts/operations/ensure-supabase-cli-session.sh`

- **Old**: `supabase/config.toml`
- **New**: `app/backend/config.toml`

## Usage

All Supabase CLI commands now run from `app/backend/`:

```bash
# Status check
npm run supabase:status

# Deploy functions
npm run deploy:functions

# Generate types
npm run supabase:types

# Create migration
npm run supabase:migrations:new

# Direct CLI usage
cd app/backend && npx --yes supabase@latest <command>
```

## Benefits
1. **Clear separation** - App code under `app/`, dev tools under `dev-tools/`, integration under `integration/`
2. **No symlinks** - Eliminates confusion and path resolution issues
3. **Consolidated** - All Supabase files in one location
4. **Maintainable** - Easier to understand and navigate
5. **Consistent** - Matches Supabase best practices while preserving ProspectPro's logical structure

## Validation

To verify the migration:
```bash
cd app/backend
npx --yes supabase@latest status
```

## Related Files
- Original migration plan: `dev-tools/workspace/context/session_store/REPO_RESTRUCTURE_PLAN.md`
- Coverage log: `dev-tools/workspace/context/session_store/coverage.md`
- Settings staging: `docs/tooling/settings-staging.md`
