#!/usr/bin/env bash
# Canonical dotenv hydration script for ProspectPro
# Hydrates both .env.local (frontend/dev) and dev-tools/agents/.env.agent.local (agent/server-side)
# Usage: ./hydrate-dotenvs.sh [local|agent|both] (default: both)

set -euo pipefail

MODE="both"
if [[ $# -gt 0 ]]; then
  MODE="$1"
fi

# Hydrate .env.local (frontend/dev)
hydrate_local() {
  echo "\n--- Hydrating .env.local (frontend/dev) ---"
  if [[ -n "${VERCEL_TOKEN:-}" ]]; then
    echo "Using VERCEL_TOKEN from environment."
    npx vercel env pull --environment=production --yes -t "$VERCEL_TOKEN" .env.local
  else
    echo "No VERCEL_TOKEN set; running vercel env pull (may prompt for login)"
    npx vercel env pull --environment=production --yes .env.local
  fi
  echo "✅ .env.local hydrated."
}

# Hydrate dev-tools/agents/.env.agent.local (agent/server-side)
hydrate_agent() {
  echo "\n--- Hydrating dev-tools/agents/.env.agent.local (agent/server-side) ---"
  ENV_FILE="dev-tools/agents/.env.agent.local"
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  if [[ -z "${VERCEL_TOKEN:-}" ]]; then
    echo "❌ VERCEL_TOKEN is not set in the environment. Please set it as a Codespaces or CI secret/variable before running." >&2
    exit 1
  fi
  VERCEL_TOKEN_ENV="$VERCEL_TOKEN"
  if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
    echo "❌ SUPABASE_ACCESS_TOKEN is not set. Export it before running." >&2
    exit 1
  fi
  if [[ -z "${SUPABASE_PROJECT_REF:-}" ]]; then
    echo "❌ SUPABASE_PROJECT_REF is not set. Export it before running." >&2
    exit 1
  fi

  echo "# ProspectPro Agent Credentials (hydrated)" >"$tmp"
  echo "# Generated $(date -u +%Y-%m-%dT%H:%M:%SZ)" >>"$tmp"
  echo >>"$tmp"

  echo "# Shared settings (Vercel)" >>"$tmp"
  npx vercel env pull --environment=production --yes -t "$VERCEL_TOKEN_ENV" "$tmp"

  echo >>"$tmp"
  echo "# Supabase project secrets" >>"$tmp"
  npx supabase secrets list --project-ref "${SUPABASE_PROJECT_REF}" --output json |
    jq -r '.[] | select(.name | test("^(AGENT_|VITE_|SUPABASE_|VERCEL_|GITHUB_|HIGHLIGHT_|EDGE_|GOOGLE_|NEVERBOUNCE_|HUNTER_|FOURSQUARE_|STRIPE_|COBALT_|APOLLO_|CENSUS_|USPTO_|SOCRATA_|PEOPLE_DATA_LABS_|BUSINESS_LICENSE_LOOKUP_|FINRA_|ZEROBOUNCE_|COUTRLISTENER_)") ) | "\(.name)=\(.value)"' >>"$tmp"

  if [[ -n "${GH_TOKEN:-}" ]]; then
    echo >>"$tmp"
    echo "# GitHub overrides" >>"$tmp"
    echo "GITHUB_PERSONAL_ACCESS_TOKEN=${GH_TOKEN}" >>"$tmp"
  fi

  echo "VERCEL_TOKEN=$VERCEL_TOKEN_ENV" >>"$tmp"

  sort -u "$tmp" >"$ENV_FILE"
  echo "✅ $ENV_FILE hydrated."
}

if [[ "$MODE" == "local" ]]; then
  hydrate_local
elif [[ "$MODE" == "agent" ]]; then
  hydrate_agent
else
  hydrate_local
  hydrate_agent
fi

echo "\nAll requested dotenvs hydrated."
