const { config, webpackConfig } = require("@rails/webpacker");
const overrideConfig = require("./src/override-config");
const WebpackerPwa = require("webpacker-pwa");

// eslint-disable-next-line no-new
new WebpackerPwa(config, webpackConfig);

module.exports = Object.assign(webpacker, { // eslint-disable-line
  webpackConfig: overrideConfig(webpackConfig)
});
