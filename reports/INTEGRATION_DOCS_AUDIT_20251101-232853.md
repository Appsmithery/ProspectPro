# Integration & Documentation Audit Report

**Date:** $(date +%Y-%m-%d)
**Phase:** 5 - Cleanup Preparation
**Purpose:** Identify deprecated code, duplicates, broken links, and outdated references

## Summary


### Deprecated Code References

```
/home/runner/work/ProspectPro/ProspectPro/integration/monitoring/diagnostics/edge-function-diagnostics.sh:50:  local report_dir="dev-tools/workspace/context/session_store/diagnostics"
/home/runner/work/ProspectPro/ProspectPro/integration/monitoring/observability/supabase-pull-logs.sh:19:source dev-tools/scripts/operations/ensure-supabase-cli-session.sh
/home/runner/work/ProspectPro/ProspectPro/integration/monitoring/observability/supabase-pull-logs.sh:20:mkdir -p dev-tools/workspace/context/session_store/diagnostics
/home/runner/work/ProspectPro/ProspectPro/integration/monitoring/observability/supabase-pull-logs.sh:21:LOG_FILE="dev-tools/workspace/context/session_store/diagnostics/${FUNC_SLUG}-$(date +%Y%m%d-%H%M%S).log"
/home/runner/work/ProspectPro/ProspectPro/integration/environments/environments.yml:4:# Generate via: node dev-tools/scripts/automation/generate-configs.mjs
/home/runner/work/ProspectPro/ProspectPro/integration/environments/environments.yml:38:      args: ["dev-tools/agents/mcp-servers/environments/development.js"]
/home/runner/work/ProspectPro/ProspectPro/integration/environments/environments.yml:78:      args: ["dev-tools/agents/mcp-servers/environments/production.js"]
/home/runner/work/ProspectPro/ProspectPro/integration/environments/environments.yml:116:      args: ["dev-tools/agents/mcp-servers/environments/production.js"]
/home/runner/work/ProspectPro/ProspectPro/integration/environments/development.json:38:      "dev-tools/agents/mcp-servers/environments/development.js"
/home/runner/work/ProspectPro/ProspectPro/integration/environments/staging.json:44:      "dev-tools/agents/mcp-servers/environments/production.js"
/home/runner/work/ProspectPro/ProspectPro/integration/environments/production.json:42:      "dev-tools/agents/mcp-servers/environments/production.js"
/home/runner/work/ProspectPro/ProspectPro/integration/platform/github/docs-automation/mermaid-template-registry.js:4:  "dev-tools": "docs/dev-tools/diagrams/",
/home/runner/work/ProspectPro/ProspectPro/integration/platform/github/docs-automation/mermaid-template-registry.json:3:  "dev-tools": "docs/dev-tools/diagrams/",
/home/runner/work/ProspectPro/ProspectPro/integration/platform/vercel/vercel-status-check.sh:14:mkdir -p dev-tools/workspace/context/session_store/deployments
/home/runner/work/ProspectPro/ProspectPro/integration/platform/vercel/vercel-status-check.sh:15:REPORT_FILE="dev-tools/workspace/context/session_store/deployments/vercel-status-$(date +%Y%m%d-%H%M%S).json"
/home/runner/work/ProspectPro/ProspectPro/integration/infrastructure/scripts/snapshot-pre-move.sh:5:tree -L 2 "$repo_root/app" "$repo_root/supabase" "$repo_root/tooling" > "$repo_root/dev-tools/workspace/context/session_store/pre-move-tree.txt"
/home/runner/work/ProspectPro/ProspectPro/integration/infrastructure/scripts/snapshot-pre-move.sh:6:find "$repo_root/app/frontend" -maxdepth 1 -type f > "$repo_root/dev-tools/workspace/context/session_store/frontend-files.txt"
/home/runner/work/ProspectPro/ProspectPro/integration/infrastructure/scripts/snapshot-pre-move.sh:7:echo "Inventory snapshots saved to dev-tools/workspace/context/session_store/pre-move-tree.txt and dev-tools/workspace/context/session_store/frontend-files.txt"
/home/runner/work/ProspectPro/ProspectPro/integration/infrastructure/scripts/migration-phase.sh:8:rm -rf ./node_modules ./dev-tools/agents/mcp/node_modules
/home/runner/work/ProspectPro/ProspectPro/integration/infrastructure/scripts/migration-phase.sh:17:cp dev-tools/agents/mcp-servers/v2/registry.v2.json dev-tools/agents/mcp-servers/registry.json
/home/runner/work/ProspectPro/ProspectPro/integration/infrastructure/scripts/migration-phase.sh:53:bash dev-tools/agents/scripts/context-snapshot.sh --dry-run
/home/runner/work/ProspectPro/ProspectPro/docs/scripts/update-docs.js:20:  "dev-tools/workspace/context/session_store"
/home/runner/work/ProspectPro/ProspectPro/docs/scripts/update-docs.js:305:    `\n## Maintenance Commands\n\n\`\`\`bash\n# Full documentation update\nnpm run docs:update\n\n# Validate MCP and Supabase contexts\nnpm run validate:contexts\nsource dev-tools/scripts/operations/ensure-supabase-cli-session.sh\n\`\`\`\n`
/home/runner/work/ProspectPro/ProspectPro/docs/scripts/update-docs.js:312:    "source dev-tools/scripts/operations/ensure-supabase-cli-session.sh"
/home/runner/work/ProspectPro/ProspectPro/docs/scripts/repo_scan.sh:15:exec "$ROOT_DIR/dev-tools/automation/ci-cd/repo_scan.sh" "$@"
/home/runner/work/ProspectPro/ProspectPro/docs/scripts/check-docs-schema.sh:148:# ...existing code from dev-tools/scripts/tooling/check-docs-schema.sh
/home/runner/work/ProspectPro/ProspectPro/docs/technical/SYSTEM_REFERENCE.md:138:source dev-tools/scripts/operations/ensure-supabase-cli-session.sh
/home/runner/work/ProspectPro/ProspectPro/docs/technical/SYSTEM_REFERENCE.md:145:source dev-tools/scripts/operations/ensure-supabase-cli-session.sh
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:104:   - Remove original `dev-tools/` directory after validation period
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:148:- Searches for legacy dev-tools/ imports
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:149:- Checks if old dev-tools/ directory removed (Phase 5 indicator)
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:271:   - Defines path mappings for `@frontend/*`, `@backend/*`, `@shared/*`, `@dev-tools/*`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:277:     - `dev-tools/agents/mcp-servers/*`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:278:     - `dev-tools/agents/client-service-layer`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:279:     - `dev-tools/observability/highlight-node`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:286:   - Created `dev-tools/scripts/automation/migration-dry-run.sh`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:313:- Removed `dev-tools/testing/Taskfile.yml` and all per-suite Taskfiles so the testing tree only holds test assets.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:314:- Added shared helper `dev-tools/agents/Taskfile.base.yml` and new Taskfiles under each agent profile to orchestrate Highlight bootstrap, env validation, and Vitest/Playwright runs.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:321:- Scaffolded `dev-tools/observability/highlight-node/` with `initHighlightNode`, middleware, and edge helpers (no-op fallback for Deno/Edge).
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:333:- Updated `.vscode/tasks.json` to run `task -d dev-tools/testing agents:*` for lint, unit, integration, e2e, full, watch, and coverage targets.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:334:- Added a Task CLI shim for `task -d dev-tools/testing reports:clean` to replace the legacy npm cleanup script.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:338:- Migrated all agent test orchestration tasks in `.vscode/tasks.json` (unit, integration, e2e, full) to use root Task CLI wrappers (`task agents:test:<target>`), replacing the previous `dev-tools/testing` Taskfile delegates.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:341:- See `dev-tools/agents/Taskfile.base.yml` plus per-profile Taskfiles for authoritative task definitions.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:347:- These tasks invoke `task` in `dev-tools/testing` and are discoverable in the VS Code Test group.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:355:- Update `.vscode/launch.json` to replace deprecated `integration/environments/*.env` references with generated `.env.<env>` files under `dev-tools/agents`.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:357:- Ensure `.vscode/mcp_config.json` memory path points to `dev-tools/workspace/context/session_store/memory.jsonl` and matches the Utility MCP config.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:372:- See patch log in dev-tools/workspace/context/session_store/Optimized Environment Config Patch Plan.md for details.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:378:- Replaced `.vscode/mcp_config.json` to remove all legacy/retired gallery servers per integration plan in `dev-tools/workspace/context/session_store/mcp-integration-plan.md`.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:406:- Maintenance: Monthly run of `dev-tools/scripts/automation/remove-legacy-paths.sh`, log results in `dev-tools/reports/`.
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:422:- All logs now route to `dev-tools/reports/ci/`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:457:  - Run: `cd dev-tools/agents/client-service-layer && npm install && npm run build && npm test`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:468:- Backed up and cleaned dev-tools/agents/mcp-servers/ per audit plan
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:476:- Test suites relocated to dev-tools/testing/agents/<agent>/{unit,e2e}
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:477:- Fixtures centralized in dev-tools/testing/utils/fixtures/
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:502:- `../scripts/operations` → `../../dev-tools/scripts/operations`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:514:All now use `cd app/backend && source ../../dev-tools/scripts/operations/ensure-supabase-cli-session.sh`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:525:- `dev-tools/scripts/setup/.codespaces-init.sh`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:574:- `dev-tools/workspace/context/session_store/coverage.md`
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:575:- `dev-tools/workspace/context/session_store/app-filetree.txt`
/home/runner/work/ProspectPro/ProspectPro/docs/app/diagrams/application-overview.mmd:45:        ReportsArchive[/dev-tools/reports/]:::storage
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/update-indexes.mjs:9:const REPO_GPS_DIR = "dev-tools/context/repo-GPS";
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/update-indexes.mjs:14:  "dev-tools/workspace/context/session_store/live-tooling-list.txt";
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/diagrams.manifest.json:8:    "docs/diagrams/dev-tools/architecture/",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/diagrams.manifest.json:9:    "docs/diagrams/dev-tools/ci-cd/",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/diagrams.manifest.json:10:    "docs/diagrams/dev-tools/agent-flows/",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/diagrams.manifest.json:11:    "docs/diagrams/dev-tools/erd/"
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/validate-mermaid-diagrams.sh:4:npm run lint -- docs/app/diagrams docs/dev-tools/diagrams docs/integration/diagrams docs/shared/mermaid
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:13:    "docs/dev-tools/diagrams",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:71:            elif "docs/dev-tools/diagrams" in path_str:
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:121:### Dev Tools Diagrams (`docs/dev-tools/diagrams/`)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:195:        "2. Consolidate to domain-specific folders (`docs/app/diagrams/`, `docs/dev-tools/diagrams/`, `docs/integration/diagrams/`)",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/add-yaml-frontmatter.py:12:    "docs/dev-tools/diagrams",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-diagrams.mjs:2:// Usage: node dev-tools/scripts/docs/generate-diagrams.mjs
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-diagrams.mjs:10:  "docs/dev-tools/diagrams",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/fix-all-diagrams.py:11:    "docs/dev-tools/diagrams",
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/run-mermaid-automation.sh:27:  git add docs/diagrams docs/mmd-shared dev-tools/workspace/context/session_store/live-tooling-list.txt
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:51:for file in docs/diagrams/dev-tools/architecture/*.mmd; do
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:54:  target="docs/dev-tools/diagrams/architecture/$basename"
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:60:for file in docs/diagrams/dev-tools/sequence/*.mmd; do
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:63:  target="docs/dev-tools/diagrams/sequence/$basename"
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:69:for file in docs/diagrams/dev-tools/automation/*.mmd; do
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:72:  target="docs/dev-tools/diagrams/automation/$basename"
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:78:for file in docs/diagrams/dev-tools/observability/*.mmd; do
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:81:  target="docs/dev-tools/diagrams/observability/$basename"
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:87:for file in docs/diagrams/dev-tools/navigation/*.mmd; do
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/consolidate-diagrams.sh:90:  target="docs/dev-tools/diagrams/navigation/$basename"
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/fix-all-diagrams.sh:105:done < <(find docs/app/diagrams docs/dev-tools/diagrams docs/integration/diagrams -name "*.mmd" -type f -print0 2>/dev/null)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/config/settings-staging.md:7:- **Change:** Pointed Mermaid snippets to `docs/shared/mermaid/config/mermaid.json`; updated MCP server paths in `.vscode/settings.json`, `.vscode/launch.json`, `.vscode/tasks.json`, and `.vscode/mcp_config.json` to the consolidated `dev-tools/agents/mcp-servers` location; refreshed watcher/search exclusions.
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/config/settings-staging.md:14:- **Change:** Updated `.vscode/mcp_config.json` entries to reference `dev-tools/agents/mcp-servers` for all local MCP node servers to mirror the finalized directory name.
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/config/settings-staging.md:15:- **Rationale:** Align VS Code MCP hooks with the new `dev-tools/agents/mcp-servers/` tree.
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/config/settings-staging.md:17:- **Rollback:** Restore prior `dev-tools/agents/servers` references if the new directory is unavailable.
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/config/navigation-index.md:21:- [Dev Tools Architecture](../../docs/dev-tools/diagrams/dev-tools-architecture.mmd)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/config/navigation-index.md:22:- [Dev Tools Sequence](../../docs/dev-tools/diagrams/dev-tools-sequence.mmd)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/guidelines/diagram-guidelines.md:54:5. **Record Provenance** – Document diagram-touching workstreams in `dev-tools/context/session_store/coverage.md` or linked runbooks to maintain auditability.
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/guidelines/DOCUMENTATION_STANDARDS.md:8:- Provenance for diagram changes must be logged in `dev-tools/context/session_store/coverage.md`.
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/guidelines/DOCUMENTATION_STANDARDS.md:38:- PRs touching app/** or dev-tools/** must update FAST_README and relevant .mmd/.mermaid files
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/guidelines/DOCUMENTATION_STANDARDS.md:62:- Provenance for diagram changes must be logged in `dev-tools/context/session_store/coverage.md`.
/home/runner/work/ProspectPro/ProspectPro/docs/dev-tools/testing/playwright-react-devtools.md:21:- Document inspection workflow in `docs/dev-tools/testing/react-devtools.md`.
/home/runner/work/ProspectPro/ProspectPro/docs/dev-tools/testing/playwright-react-devtools.md:32:- Persist artifacts to `dev-tools/reports/e2e/` and note coverage deltas in `coverage.md`.
/home/runner/work/ProspectPro/ProspectPro/docs/shared/mermaid/CONSOLIDATION_REPORT.md:33:├── dev-tools/diagrams/    (7 files)
/home/runner/work/ProspectPro/ProspectPro/docs/shared/mermaid/CONSOLIDATION_REPORT.md:36:    ├── dev-tools/         (8 files)
/home/runner/work/ProspectPro/ProspectPro/docs/shared/mermaid/CONSOLIDATION_REPORT.md:45:├── dev-tools/diagrams/    (11 files) ✓ +4 moved
/home/runner/work/ProspectPro/ProspectPro/docs/shared/mermaid/CONSOLIDATION_REPORT.md:54:docs/dev-tools/diagrams/
/home/runner/work/ProspectPro/ProspectPro/docs/shared/mermaid/MAINTENANCE_CHECKLIST.md:87:git checkout HEAD -- docs/app/diagrams docs/dev-tools/diagrams docs/integration/diagrams
/home/runner/work/ProspectPro/ProspectPro/docs/shared/mermaid/MIGRATION_SUMMARY.md:198:- ✅ All `.mmd` files in `docs/dev-tools/diagrams/`
```

### Potential Duplicate Files

- README.md
/home/runner/work/ProspectPro/ProspectPro/docs/README.md
/home/runner/work/ProspectPro/ProspectPro/docs/app/README.md
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/README.md
- settings-staging.md
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/config/settings-staging.md

### Internal Links to Review

Found 45 markdown links that should be validated:

```
/home/runner/work/ProspectPro/ProspectPro/docs/scripts/update-docs.js:230:      "[docs/technical/CODEBASE_INDEX.md](docs/technical/CODEBASE_INDEX.md) — Auto-generated index consumed by #codebase",
/home/runner/work/ProspectPro/ProspectPro/docs/scripts/update-docs.js:231:      "[.github/copilot-instructions.md](.github/copilot-instructions.md) — AI assistant operating instructions",
/home/runner/work/ProspectPro/ProspectPro/docs/technical/CODEBASE_INDEX.md:34:- [docs/technical/CODEBASE_INDEX.md](docs/technical/CODEBASE_INDEX.md) — Auto-generated index consumed by #codebase
/home/runner/work/ProspectPro/ProspectPro/docs/technical/CODEBASE_INDEX.md:35:- [.github/copilot-instructions.md](.github/copilot-instructions.md) — AI assistant operating instructions
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:15:- **[Copilot Instructions](../.github/copilot-instructions.md)** – Authoritative production guide (deployment, troubleshooting, SLAs)
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:16:- **[README](../README.md)** – Platform overview and quickstart
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:17:- **[ARCHITECTURE_DECISION_BACKGROUND_TASKS.md](archived/ARCHITECTURE_DECISION_BACKGROUND_TASKS.md)** – Rationale for asynchronous discovery orchestration
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:18:- **[BACKGROUND_TASKS_IMPLEMENTATION.md](../development/archived/BACKGROUND_TASKS_IMPLEMENTATION.md)** – Implementation notes for `business-discovery-background`
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:19:- **[PRODUCTION_READY_V4.4.md](../deployment/PRODUCTION_READY_V4.4.md)** – Release summary for the user-aware deduplication launch
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:43:> ℹ️ Session JWTs are mandatory for every authenticated Edge Function call. Use [`EDGE_FUNCTION_AUTH_UPDATE_GUIDE.md`](../setup/archived/EDGE_FUNCTION_AUTH_UPDATE_GUIDE.md) plus `scripts/test-auth-patterns.sh` to validate flows.
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:121:- Publishable key or session mismatch: [`EDGE_FUNCTION_AUTH_UPDATE_GUIDE.md`](../setup/archived/EDGE_FUNCTION_AUTH_UPDATE_GUIDE.md), [`NEED_ANON_KEY.md`](../setup/archived/NEED_ANON_KEY.md) (historical reference only).
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:124:- Dedup validation or ledger anomalies: [`PRODUCTION_READY_V4.4.md`](../deployment/PRODUCTION_READY_V4.4.md) (deployment + validation checklist).
/home/runner/work/ProspectPro/ProspectPro/docs/README.md:125:- Deployment checklist: [`DEPLOYMENT_CHECKLIST.md`](../deployment/archived/DEPLOYMENT_CHECKLIST.md).
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:155:- [Enhanced Diagram Standards](../guidelines/enhanced-diagram-standards.md)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:156:- [Mermaid Syntax Guide](../guidelines/mermaid-syntax-guide.md)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:157:- [Suite README](../README.md)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:158:- [Migration Summary](../MIGRATION_SUMMARY.md)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/scripts/generate-index.py:159:- [Maintenance Checklist](../MAINTENANCE_CHECKLIST.md)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/README.md:291:  - [Enhanced Diagram Standards](./guidelines/enhanced-diagram-standards.md)
/home/runner/work/ProspectPro/ProspectPro/docs/mmd-shared/README.md:292:  - [Diagram Guidelines](./guidelines/diagram-guidelines.md)
... (showing first 20 of 45)
```

### Outdated Migration References

```
/home/runner/work/ProspectPro/ProspectPro/integration/monitoring/diagnostics/debug-campaign.sql:50:  EXTRACT(EPOCH FROM (dj.completed_at - dj.started_at)) as job_duration_seconds,
/home/runner/work/ProspectPro/ProspectPro/integration/symlinks/platform-detector.js:25:    "Warning: Found old supabase symlink - migration may be incomplete"
/home/runner/work/ProspectPro/ProspectPro/integration/symlinks/validate-symlinks.sh:17:  echo "Warning: Found old supabase symlink - migration may be incomplete" >&2
/home/runner/work/ProspectPro/ProspectPro/integration/infrastructure/scripts/migration-phase.sh:62:echo "Migration phase automation complete."
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:13:- Kept only dev-tools-package workspace entries as Phase 4 integration is complete
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:32:## Phase 4 Integration Complete ✅
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:37:**Status:** Phase 4 integration successfully completed  
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:193:## Phase 3 Execution Complete ✅
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:198:**Status:** Phase 3 extraction successfully completed  
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:230:   - EXTRACTION_MANIFEST.md created with complete extraction details
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:256:### Repository Restructure - Phase 2 Complete
/home/runner/work/ProspectPro/ProspectPro/docs/tooling/settings-staging.md:261:   - Updated document status from "Planning Phase" to "Phase 2 Complete - Ready for Phase 3 Implementation"
```

## Audit Statistics

- Deprecated code references: 105
- Potential duplicate files: 2
- Internal links to review: 45
- Outdated migration references: 12

## Conclusion

⚠️ **ATTENTION REQUIRED** - Found 164 potential issues to review before Phase 5.

