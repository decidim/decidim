const { webpackConfig, ...restOpts } = require("@rails/webpacker");
const overrideConfig = require("./src/override-config");

module.exports = {
  webpackConfig: overrideConfig(webpackConfig),
  ...restOpts
};
