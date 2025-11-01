import path from "path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    globals: true,
    setupFiles: ["dev-tools/testing/utils/setup.ts"],
    coverage: {
      provider: "v8",
      reportsDirectory: "./reports/coverage",
      reporter: ["text", "html", "json"],
      include: [
        "dev-tools/testing/agents/**/unit/**/*.test.ts",
        "dev-tools/testing/agents/**/integration/**/*.test.ts",
        "dev-tools/testing/agents/**/e2e/**/*.test.ts",
        "**/__tests__/**/*.test.ts",
        "**/__tests__/**/*.integration.ts",
      ],
      exclude: [
        "**/node_modules/**",
        "**/dist/**",
        "**/e2e/**",
        "**/*.spec.ts",
        "**/e2e/**/*.ts",
        "**/e2e/**/*.js",
      ],
    },
    reporters: [
      "default",
      ["json", { outputFile: "./reports/vitest-results.json" }],
    ],
    include: [
      "dev-tools/testing/agents/**/unit/**/*.test.ts",
      "dev-tools/testing/agents/**/integration/**/*.test.ts",
      "dev-tools/testing/agents/**/e2e/**/*.test.ts",
      "**/__tests__/**/*.test.ts",
      "**/__tests__/**/*.integration.ts",
    ],
  },
  resolve: {
    alias: {
      "@agents": path.resolve(__dirname, "../agents"),
      "@testing": path.resolve(__dirname, ".."),
      "@observability": path.resolve(__dirname, "../observability"),
      "@fixtures": path.resolve(__dirname, "../fixtures"),
    },
  },
});
