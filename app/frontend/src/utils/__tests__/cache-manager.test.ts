import { CacheManager } from "@backend/functions/_shared/cache-manager";
import { describe, expect, it } from "vitest";

describe("CacheManager", () => {
  describe("normalizeParams", () => {
    it("should normalize and sort params, removing empty values", () => {
      // @ts-expect-error: access private method for test
      const result = CacheManager.prototype.constructor["normalizeParams"]({
        b: "  ",
        a: "foo",
        c: null,
        d: undefined,
        e: [null, "bar", ""],
        f: { x: "", y: "baz", z: null },
      });
      expect(result).toEqual({
        a: "foo",
        e: ["bar"],
        f: { y: "baz" },
      });
    });
  });

  describe("generateCacheKey", () => {
    it("should throw if Supabase env is missing", async () => {
      // Patch Deno.env.get to simulate missing env
      const originalGet = globalThis.Deno?.env.get;
      globalThis.Deno = {
        env: {
          get: (name: string) => undefined,
        },
      } as any;
      const cm = new CacheManager();
      await expect(cm["generateCacheKey"]("foo", { bar: 1 })).rejects.toThrow(
        "Missing required environment variable"
      );
      // Restore
      if (originalGet) globalThis.Deno.env.get = originalGet;
    });
  });
});
