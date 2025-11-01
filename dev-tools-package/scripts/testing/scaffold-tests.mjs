#!/usr/bin/env node
import { promises as fs } from "fs";
import path from "path";

const root = path.resolve(process.cwd(), "app/tests");
const requiredDirs = ["unit", "integration", "e2e", "deno"];
const placeholder = (name, type) => {
  if (type === "unit" || type === "integration") {
    return `import { describe, expect, it } from "vitest";

describe("${name} ${type} tests", () => {
  it("should pass placeholder test", () => {
    expect(true).toBe(true);
  });
});
`;
  } else if (type === "e2e") {
    return `import { expect, test } from "@playwright/test";

test.describe("${name} E2E", () => {
  test("should load homepage", async ({ page }) => {
    await page.goto("/");
    expect(await page.title()).toBeDefined();
  });
});
`;
  } else if (type === "deno") {
    return `// Deno test placeholder for ${name}
Deno.test("${name} Deno test", () => {
  if (1 !== 1) throw new Error('Placeholder fail');
});
`;
  }
  return "";
};

async function ensureDir(dir) {
  try {
    await fs.mkdir(dir, { recursive: true });
  } catch {}
}

async function ensureFile(file, content) {
  try {
    await fs.access(file);
  } catch {
    await fs.writeFile(file, content, "utf8");
  }
}

async function main() {
  for (const dir of requiredDirs) {
    const dirPath = path.join(root, dir);
    await ensureDir(dirPath);
    // Add a placeholder if no test files exist
    const files = (await fs.readdir(dirPath)).filter((f) => f.endsWith(".ts"));
    if (files.length === 0) {
      const fileName = `${dir}-placeholder.${
        dir === "e2e" ? "spec" : dir === "deno" ? "test" : "test"
      }.ts`;
      await ensureFile(path.join(dirPath, fileName), placeholder(dir, dir));
    }
  }
  console.log("Test scaffolding complete.");
}

main().catch((e) => {
  console.error("Scaffolding failed:", e);
  process.exit(1);
});
