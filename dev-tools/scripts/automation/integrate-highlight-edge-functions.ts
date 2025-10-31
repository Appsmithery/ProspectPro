#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env
/**
 * This is a Deno script. TypeScript errors are expected when checked with Node.js tsc.
 * Run with: deno run --allow-read --allow-write --allow-env dev-tools/scripts/automation/integrate-highlight-edge-functions.ts
 */

import { walk } from "https://deno.land/std@0.208.0/fs/walk.ts";
import {
  dirname,
  join,
  parse,
} from "https://deno.land/std@0.208.0/path/mod.ts";

const REPO_ROOT = Deno.env.get("REPO_ROOT") || Deno.cwd();
const FUNCTIONS_DIR = join(REPO_ROOT, "app/backend/functions");

interface EdgeFunction {
  path: string;
  name: string;
  needsIntegration: boolean;
}

async function inventoryEdgeFunctions(): Promise<EdgeFunction[]> {
  const functions: EdgeFunction[] = [];

  for await (const entry of walk(FUNCTIONS_DIR, {
    match: [/index\.ts$/],
    includeDirs: false,
  })) {
    const content = await Deno.readTextFile(entry.path);
    const needsIntegration =
      !content.includes("withHighlightEdge") &&
      !content.includes("initHighlightNode");

    functions.push({
      path: entry.path,
      name: parse(dirname(entry.path)).name,
      needsIntegration,
    });
  }

  return functions;
}

async function integrateHighlight(func: EdgeFunction): Promise<void> {
  let content = await Deno.readTextFile(func.path);

  // Add import if not present
  if (!content.includes("withHighlightEdge")) {
    const importStatement = `import { withHighlightEdge } from "../_shared/highlight-node.ts";\n`;
    content = importStatement + content;
  }

  // Wrap handler
  const handlerPattern = /export\s+default\s+async\s+function\s+(\w+)\s*\(/;
  const match = content.match(handlerPattern);

  if (match) {
    const handlerName = match[1];
    content = content.replace(
      handlerPattern,
      `const ${handlerName}Internal = async (`
    );
    content += `\n\nexport default withHighlightEdge(${handlerName}Internal);\n`;
  }

  await Deno.writeTextFile(func.path, content);
  console.log(`✓ Integrated Highlight into ${func.name}`);
}

// Main execution
const functions = await inventoryEdgeFunctions();
const needsWork = functions.filter((f) => f.needsIntegration);

console.log(`Found ${needsWork.length} edge functions needing integration`);

for (const func of needsWork) {
  await integrateHighlight(func);
}

console.log("\n✓ Edge function integration complete");
