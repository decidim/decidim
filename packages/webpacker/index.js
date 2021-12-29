const webpacker = require("@rails/webpacker");
const overrideConfig = require("./src/override-config");

module.exports = Object.assign(webpacker, { // eslint-disable-line
  webpackConfig: overrideConfig(webpacker.webpackConfig)
});
