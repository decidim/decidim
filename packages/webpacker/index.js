const { generateWebpackConfig, ...restOpts } = require("shakapacker");
const webpackConfig = generateWebpackConfig()

const overrideConfig = require("./src/override-config");

module.exports = {
  webpackConfig: overrideConfig(webpackConfig),
  ...restOpts
};
