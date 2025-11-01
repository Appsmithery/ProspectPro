#!/usr/bin/env bash
# Validate Supabase migration - no longer requires symlinks
set -euo pipefail

# Post-migration validation: ensure app/backend exists instead of root symlink
if [[ ! -d "app/backend" ]]; then
  echo "Missing directory: app/backend (post-migration structure)" >&2
  exit 1
fi

if [[ ! -f "app/backend/config.toml" ]]; then
  echo "Missing file: app/backend/config.toml" >&2
  exit 1
fi

if [[ -L "supabase" ]]; then
  echo "Warning: Found old supabase symlink - migration may be incomplete" >&2
  exit 1
fi

echo "Post-migration validation: app/backend structure [OK]"
