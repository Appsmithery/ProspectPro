// moved from dev-tools/testing/agents/context/e2e/context.spec.ts
// ...existing code from context.spec.ts will be inserted here...
import { expect, test } from "@playwright/test";

test.describe("context E2E", () => {
  test("should load homepage", async ({ page }) => {
    await page.goto("/");
    expect(await page.title()).toBeDefined();
  });
});
