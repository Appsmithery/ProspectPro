#!/bin/bash
# Export required secrets for Deno tests in app/tests/deno
# Usage: source this script before running Deno tests

# Try to source from .env.local if present
ENV_FILE="/workspaces/ProspectPro/.env.local"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | grep -E 'SUPABASE_SESSION_JWT|SUPABASE_ANON_KEY|SUPABASE_PUBLISHABLE_KEY|SUPABASE_FUNCTION_BASE_URL|EDGE_AUTH_DEV_BYPASS' | xargs)
fi

# Fallback: prompt for SUPABASE_SESSION_JWT if not set
if [ -z "$SUPABASE_SESSION_JWT" ]; then
  echo "SUPABASE_SESSION_JWT is not set. Please export it manually or add it to .env.local."
fi

# Export other required variables if present
if [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "SUPABASE_ANON_KEY is not set. Please export it manually or add it to .env.local."
fi
