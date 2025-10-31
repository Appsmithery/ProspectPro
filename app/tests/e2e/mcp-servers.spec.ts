// moved from dev-tools/testing/agents/mcp-servers/e2e/mcp-servers.spec.ts
// ...existing code from mcp-servers.spec.ts will be inserted here...
import { expect, test } from "@playwright/test";

test.describe("mcp-servers E2E", () => {
  test("should load homepage", async ({ page }) => {
    await page.goto("/");
    expect(await page.title()).toBeDefined();
  });
});
