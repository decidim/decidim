const { generateWebpackConfig, ...restOpts } = require("shakapacker");
const { EsbuildPlugin } = require("esbuild-loader")

const options = {
  optimization: {
    minimizer: [
      new EsbuildPlugin({
        target: "es2015"
      })
    ]
  }
}

const webpackConfig = generateWebpackConfig(options)
const overrideConfig = require("./src/override-config");

module.exports = {
  webpackConfig: overrideConfig(webpackConfig),
  ...restOpts
};
