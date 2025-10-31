/**
 * MCP Server Highlight Integration Adapter
 *
 * Provides request/response middleware and error handlers for MCP servers
 */

import { initHighlightNode } from "./index.js";

export interface MCPHighlightConfig {
  projectId: string;
  serviceName: string;
  environment: "development" | "staging" | "production";
}

export function createMCPHighlightMiddleware(config: MCPHighlightConfig) {
  const H = initHighlightNode(config);

  return {
    /**
     * Wrap MCP tool execution with Highlight tracing
     */
    wrapTool: <T extends (...args: any[]) => Promise<any>>(
      toolName: string,
      handler: T
    ): T => {
      return (async (...args: any[]) => {
        const traceId = `mcp.${config.serviceName}.${toolName}`;

        try {
          H.trace(traceId, { args });
          const result = await handler(...args);
          H.trace(`${traceId}.success`, { result });
          return result;
        } catch (error) {
          H.record(error as Error, {
            tool: toolName,
            service: config.serviceName,
            args,
          });
          throw error;
        }
      }) as T;
    },

    /**
     * Create session context for tool execution
     */
    createSession: (sessionId: string, metadata: Record<string, any>) => {
      H.trace("mcp.session.start", {
        sessionId,
        service: config.serviceName,
        ...metadata,
      });

      return {
        end: () => H.trace("mcp.session.end", { sessionId }),
        addEvent: (event: string, data?: Record<string, any>) => {
          H.trace(`mcp.session.${event}`, {
            sessionId,
            ...data,
          });
        },
      };
    },

    /**
     * Flush all pending Highlight events (call on server shutdown)
     */
    flush: () => H.flush(),
  };
}
