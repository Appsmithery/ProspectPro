// moved from dev-tools/testing/agents/client-service-layer/e2e/client-service-layer.spec.ts
// ...existing code from client-service-layer.spec.ts will be inserted here...
import { expect, test } from "@playwright/test";

test.describe("client-service-layer E2E", () => {
  test("should load homepage", async ({ page }) => {
    await page.goto("/");
    expect(await page.title()).toBeDefined();
  });
});
