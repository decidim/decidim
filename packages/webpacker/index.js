const { webpackConfig, ...restOpts } = require("shakapacker");
const overrideConfig = require("./src/override-config");

module.exports = {
  webpackConfig: overrideConfig(webpackConfig),
  ...restOpts
};
