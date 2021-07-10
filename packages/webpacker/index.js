const webpacker = require("@rails/webpacker");
const overrideConfig = require("./src/override-config");

module.exports = Object.assign(webpacker, {
  webpackConfig: overrideConfig(webpacker.webpackConfig)
});
