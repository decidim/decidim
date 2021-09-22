const { config } = require("@rails/webpacker");

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

  const imports = config.stylesheet_imports;
  if (!imports) {
    return modifyConfig;
  }

  // Add the extra importer to the sass-loader to load the import statements for
  // Decidim modules.
  sassLoader.options.sassOptions.importer = [
    (url) => {
      const matches = url.match(/^!decidim-style-([^[]+)\[([^\]]+)\]$/);
      if (!matches) {
        return null;
      }

      const type = matches[1];
      const group = matches[2];
      if (!imports[type] || !imports[type][group]) {
        // If the group is not defined, return an empty configuration because
        // otherwise the importer would continue finding the asset through
        // paths which obviously fails.
        return { contents: "" };
      }

      const statements = imports[type][group].map((style) => `@import "${style}";`);

      return { contents: statements.join("\n") };
    }
  ];

  return modifyConfig;
}

module.exports = (originalConfig) => { // eslint-disable-line
  return overrideSassRule(originalConfig);
};
