import { defineConfig, globalIgnores } from "eslint/config";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all
});

export default defineConfig([globalIgnores([
  "**/*.min.js",
  "**/*-min.js",
  "decidim-*/vendor/**/*.js",
  "spec/decidim_dummy_app/**/*.js",
  "**/development_app",
  "**/node_modules/**/*",
  "**/bundle.js",
  "**/karma.conf.js",
  "**/webpack.config.js",
  "**/webpack.config.babel.js",
  "**/entry.test.js",
  "**/entry.js",
  "**/*_manifest.js",
  "**/coverage",
  "decidim-dev/**/*/test/**/*.js",
  "vendor/bundle",
]), {
  extends: compat.extends("@decidim"),
}]);
