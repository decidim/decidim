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
  if (!Array.isArray(imports)) {
    return modifyConfig
  }

  // Add the extra importer to the sass-loader to load the import statements for
  // Decidim modules.
  sassLoader.options.sassOptions.importer = [
    (url, _prev) => {
      if (url !== "!decidim-style-imports") {
        return null
      }

      const statements = imports.map((style) => `@import "${style}";`)

      return { contents: statements.join("\n") }
    }
  ]

  return modifyConfig
}

const overrideConfig = (originalConfig) => {
  return overrideSassRule(originalConfig)
}

module.exports = merge(overrideConfig(webpackConfig), customConfig)
