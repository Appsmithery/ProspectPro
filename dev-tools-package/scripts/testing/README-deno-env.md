# Deno Test Environment Setup

This script helps you export the required secrets for running Deno tests in `app/tests/deno`.

## Usage

1. Ensure your `.env.local` contains the following keys (add them if missing):

   - `SUPABASE_SESSION_JWT` (required for authenticated Supabase Edge tests)
   - `SUPABASE_ANON_KEY` or `SUPABASE_PUBLISHABLE_KEY`
   - `SUPABASE_FUNCTION_BASE_URL` (optional, defaults to local stack)
   - `EDGE_AUTH_DEV_BYPASS` (optional, for dev bypass)

2. Source the script before running Deno tests:

   ```bash
   source dev-tools/scripts/testing/export-deno-env.sh
   ./dev-tools/scripts/testing/run-deno-tests.sh
   ```

3. If any required secret is missing, the script will prompt you to export it manually.

## Notes

- This script does not write secrets to disk.
- For CI, ensure secrets are injected into the environment before running tests.
- If you do not have a valid `SUPABASE_SESSION_JWT`, see the platform runbook or ask an admin for a test session token.
