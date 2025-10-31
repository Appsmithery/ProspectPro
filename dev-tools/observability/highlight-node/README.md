# Highlight Node Helper

This package provides a unified wrapper for Highlight.io's Node SDK, enabling full-stack session correlation and trace forwarding from backend agents, Supabase Edge Functions, and other Node services.

## Features

- Exports `initHighlightNode()` for initializing Highlight tracing in Node environments
- Provides Express/Fastify-style middleware helpers for easy integration
- No-op fallback if Highlight environment variables are missing
- Designed for use in agents, Supabase Edge Functions, and backend services

## Usage

```ts
import { initHighlightNode } from "dev-tools/observability/highlight-node";

const highlight = initHighlightNode();
// highlight is a no-op if env vars are missing
```

### Express/Fastify Middleware

```ts
import { highlightRequestMiddleware } from "dev-tools/observability/highlight-node";
app.use(highlightRequestMiddleware());
```

## References

- [Highlight Node SDK Docs](https://www.highlight.io/docs/sdk/nodejs)
- [Getting Started: Node.js](https://www.highlight.io/docs/getting-started/server/js/nodejs)
- [Frontend-Backend Mapping](https://www.highlight.io/docs/getting-started/frontend-backend-mapping)

## Environment Variables

- `HIGHLIGHT_PROJECT_ID` (required for real traces)
- `HIGHLIGHT_OTLP_ENDPOINT` (optional, for custom OTLP collector)

If these are not set, all helpers become no-ops.

---

This helper is part of the ProspectPro observability consolidation plan. See `/dev-tools/workspace/context/session_store/Optimized Agents Config Patch Plan.md` for details.
