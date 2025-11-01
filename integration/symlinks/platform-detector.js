// Platform detector for post-migration structure validation
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, "../..");

// Post-migration: validate app/backend structure instead of symlinks
const requiredPaths = ["app/backend", "app/backend/config.toml"];

requiredPaths.forEach((requiredPath) => {
  const fullPath = path.resolve(projectRoot, requiredPath);
  if (!fs.existsSync(fullPath)) {
    console.error(`Missing required path: ${requiredPath}`);
    process.exit(1);
  }
  console.log(`Required path ${requiredPath} [OK]`);
});

// Check for old symlink (should not exist post-migration)
const oldSymlink = path.resolve(projectRoot, "supabase");
if (fs.existsSync(oldSymlink) && fs.lstatSync(oldSymlink).isSymbolicLink()) {
  console.error(
    "Warning: Found old supabase symlink - migration may be incomplete"
  );
  process.exit(1);
}

console.log("Post-migration structure validation [OK]");
