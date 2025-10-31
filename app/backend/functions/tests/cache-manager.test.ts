import {
  assertEquals,
  assertRejects,
} from "https://deno.land/std@0.208.0/assert/mod.ts";
import { CacheManager } from "../_shared/cache-manager.ts";

// Note: This test accesses private implementation details for testing purposes.
// In a production scenario, only public APIs should be tested.
Deno.test("CacheManager - normalizeParams should normalize and sort params, removing empty values", () => {
  // @ts-expect-error: access private method for test
  const result = CacheManager.prototype.constructor["normalizeParams"]({
    b: "  ",
    a: "foo",
    c: null,
    d: undefined,
    e: [null, "bar", ""],
    f: { x: "", y: "baz", z: null },
  });
  assertEquals(result, {
    a: "foo",
    e: ["bar"],
    f: { y: "baz" },
  });
});

Deno.test("CacheManager - generateCacheKey should throw if Supabase env is missing", async () => {
  // Patch Deno.env.get to simulate missing env
  const originalGet = Deno.env.get;

  try {
    Deno.env.get = (_name: string) => undefined;

    const cm = new CacheManager();
    await assertRejects(
      async () => {
        await cm["generateCacheKey"]("foo", { bar: 1 });
      },
      Error,
      "Missing required environment variable"
    );
  } finally {
    // Restore original implementation
    Deno.env.get = originalGet;
  }
});
