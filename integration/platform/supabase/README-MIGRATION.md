# Supabase Assets Migration Notice

⚠️ **This directory has been migrated as of 2025-11-01**

## New Location
All Supabase scripts, tests, and support files have been consolidated into:
```
app/backend/
├── scripts/         (formerly integration/platform/supabase/scripts/)
├── tests/           (formerly integration/platform/supabase/tests/)
├── supabase.js      (copied)
├── supabase-ca-2021.crt (copied)
└── package-supabase.json (copied)
```

## What to Use
- **Scripts**: Use files in `app/backend/scripts/`
- **Tests**: Use files in `app/backend/tests/`
- **Supabase CLI**: Run from `app/backend/` directory
- **Documentation**: See `SUPABASE_MIGRATION.md` at repo root

## Files in This Directory
The files remaining in this directory are kept for reference only during the transition period. They may be removed in a future cleanup.

## More Information
- Migration details: `/SUPABASE_MIGRATION.md`
- Coverage log: `dev-tools/workspace/context/session_store/coverage.md`
- Settings staging: `docs/tooling/settings-staging.md`
