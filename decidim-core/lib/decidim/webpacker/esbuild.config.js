const sassPlugin = require("esbuild-sass-plugin").sassPlugin;
const { EsbuildPlugin } = require("esbuild-loader");

// eslint-disable-next-line no-undef
module.exports = {
  options: {
    tsconfigRaw: JSON.stringify({}),
    target: "es2015"
  },
  // target: ["es2015", "chrome58", "edge16", "firefox57", "safari11"],
  bundle: true,
  sourcemap: true,
  minify: true,
  outdir: "public",
  outExtension: {
    ".css": ".scss"
  },
  plugins: [sassPlugin({})],
  optimization: {
    minimizer: [
      new EsbuildPlugin({
        target: "es2015"
      })
    ]
  }
};
