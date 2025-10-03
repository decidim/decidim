// eslint-disable-next-line no-undef
module.exports = {
  options: {
    tsconfigRaw: JSON.stringify({}),
    target: "es2015"
  },
  bundle: true,
  sourcemap: true,
  minify: true,
  outdir: "public",
  outExtension: {
    ".css": ".scss"
  }
};
