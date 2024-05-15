const { generateWebpackConfig, ...restOpts } = require("shakapacker");

const webpackConfig = generateWebpackConfig();
const overrideConfig = require("./src/override-config");

// eslint-disable-next-line no-undef
module.exports = {
  webpackConfig: overrideConfig(webpackConfig),
  ...restOpts
};
