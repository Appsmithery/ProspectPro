// Deno-compatible Highlight Node helper shim for Supabase Edge Functions
// This file proxies to the canonical helper in dev-tools/observability/highlight-node/index.ts
// and provides a no-op fallback for Deno/Edge environments.

// NOTE: Deno does not support Node.js require, so we only export a no-op for now.
// If/when Highlight provides a Deno/Edge-compatible SDK, update this file to use it.

export function initHighlightNode() {
  // No-op for Deno/Supabase Edge
  return {
    record: () => {},
    trace: () => {},
    flush: () => {},
    middleware: () => (req: any, res: any, next: any) => next(),
  };
}

export function highlightRequestMiddleware() {
  return (req: any, res: any, next: any) => next();
}

export function withHighlightEdge(handler: Function) {
  return async (...args: any[]) => {
    try {
      const result = await handler(...args);
      return result;
    } catch (err) {
      // No-op error record
      throw err;
    }
  };
}
