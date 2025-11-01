#!/usr/bin/env bash
# filepath: /workspaces/ProspectPro/dev-tools/agents/scripts/hydrate-local-env.sh

set -euo pipefail

ENV_FILE="dev-tools/agents/.env.agent.local"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT




if [[ -z "${VERCEL_TOKEN:-}" ]]; then
  echo "❌ VERCEL_TOKEN is not set in the environment. Please set it as a Codespaces or CI secret/variable before running." >&2
  exit 1
fi
VERCEL_TOKEN_ENV="$VERCEL_TOKEN"
echo "ℹ️  Using Vercel token from VERCEL_TOKEN env var"
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
echo "✅ Secrets refreshed in $ENV_FILE"