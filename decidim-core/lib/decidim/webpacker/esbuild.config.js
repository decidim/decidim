const esbuild = require("esbuild");
const sassPlugin = require("esbuild-sass-plugin").sassPlugin;

esbuild.build({
  bundle: true,
  sourcemap: true,
  write: true,
  minify: true,
  outdir: "public",
  target: ["es2015", "chrome58", "edge16", "firefox57", "safari11"],
  loader: { ".scss": "css" },
  outExtension: {
    ".css": ".scss"
  },
  plugins: [sassPlugin({})]
});
