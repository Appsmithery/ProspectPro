// Unified Highlight Node helper for agents, edge functions, and backend services
import type { NextFunction, Request, Response } from "express";

let highlight: any = null;
let highlightInitialized = false;

export function initHighlightNode() {
  if (highlightInitialized) return highlight;
  const projectId = process.env.HIGHLIGHT_PROJECT_ID;
  if (!projectId) {
    highlight = createNoopHighlight();
    highlightInitialized = true;
    return highlight;
  }
  try {
    // Dynamically require to avoid breaking edge builds if not installed
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { H } = require("@highlight-run/node");
    highlight = H.init({
      projectID: projectId,
      otlpEndpoint: process.env.HIGHLIGHT_OTLP_ENDPOINT,
      serviceName: process.env.HIGHLIGHT_SERVICE_NAME || "prospectpro-agent",
      environment: process.env.NODE_ENV || "development",
    });
    highlightInitialized = true;
    return highlight;
  } catch (err) {
    // Fallback to noop if Highlight SDK is not installed
    highlight = createNoopHighlight();
    highlightInitialized = true;
    return highlight;
  }
}

function createNoopHighlight() {
  // No-op implementation for environments without Highlight
  return {
    record: () => {},
    trace: () => {},
    flush: () => {},
    middleware: () => (req: any, res: any, next: any) => next(),
  };
}

// Express/Fastify-style middleware for request tracing
export function highlightRequestMiddleware() {
  const h = initHighlightNode();
  return h.middleware
    ? h.middleware()
    : (req: Request, res: Response, next: NextFunction) => next();
}

// Utility for edge function handlers (Supabase, etc.)
export function withHighlightEdge(handler: Function) {
  const h = initHighlightNode();
  return async (...args: any[]) => {
    try {
      const result = await handler(...args);
      if (h.flush) await h.flush();
      return result;
    } catch (err) {
      if (h.record) h.record(err);
      throw err;
    }
  };
}
