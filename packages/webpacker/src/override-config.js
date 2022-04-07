const path = require("path");

const overrideSassRule = (modifyConfig) => {
  const sassRule = modifyConfig.module.rules.find(
    (rule) => rule.test.toString() === "/\\.(scss|sass)(\\.erb)?$/i"
  );
  if (!sassRule) {
    return modifyConfig;
  }

  const sassLoader = sassRule.use.find((use) => {
    return (typeof use === "object") && use.loader.match(/sass-loader/);
  });
  if (!sassLoader) {
    return modifyConfig;
  }

  sassLoader.loader = path.resolve(__dirname, "loaders/decidim-sass-loader"); // eslint-disable-line no-undef

  return modifyConfig;
}

// Since all modifiers are functions, we can use a reduce clause to apply all them
module.exports = (originalConfig) => [overrideSassRule].reduce((acc, modifier) => modifier(acc), originalConfig)
