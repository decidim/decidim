/* eslint-disable */

const { webpackConfig, merge, config } = require("@rails/webpacker")
const customConfig = require("./custom")

const overrideSassRule = (modifyConfig) => {
  const sassRule = modifyConfig.module.rules.find((rule) => rule.test.toString() === "/\\.(scss|sass)(\\.erb)?$/i")
  if (!sassRule) {
    return modifyConfig
  }

  const sassLoader = sassRule.use.find(use => use.loader.match(/sass-loader/))
  if (!sassLoader) {
    return modifyConfig
  }

  const imports = config.stylesheet_imports
  if (!imports) {
    return modifyConfig
  }

  // Add the extra importer to the sass-loader to load the import statements for
  // Decidim modules.
  sassLoader.options.sassOptions.importer = [
    (url, _prev) => {
      const matches = url.match(/^\!decidim-style-imports\[([^\]]+)\]$/);
      if (!matches) {
        return null
      }

      const group = matches[1]
      if (!imports[group]) {
        // If the group is not defined, return an empty configuration because
        // otherwise the importer would continue finding the asset through
        // paths which obviously fails.
        return { contents: "" }
      }

      const statements = imports[group].map((style) => `@import "${style}";`)

      return { contents: statements.join("\n") }
    }
  ]

  return modifyConfig
}

const overrideConfig = (originalConfig) => {
  return overrideSassRule(originalConfig)
}

module.exports = merge(overrideConfig(webpackConfig), customConfig)
