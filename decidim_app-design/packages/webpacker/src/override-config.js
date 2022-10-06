const path = require("path");
const miniCssExtractPlugin = require("mini-css-extract-plugin");
const { inliningCss } = require("@rails/webpacker");

const overrideSassRule = (modifyConfig) => {
  const sassLoaderPath = path.resolve(__dirname, "loaders/decidim-sass-loader") // eslint-disable-line no-undef

  const sassRule = modifyConfig.module.rules.find(
    (rule) => rule.test.toString() === "/\\.(scss|sass)(\\.erb)?$/i"
  );
  if (sassRule) {
    const existingLoader = sassRule.use.find((use) => {
      return (typeof use === "object") && use.loader.match(/sass-loader/);
    });
    if (existingLoader) {
      existingLoader.loader = sassLoaderPath;
    } else {
      sassRule.use.push({ loader: sassLoaderPath });
    }
  } else {
    // Add the sass rule
    let baseLoader = "style-loader";
    if (!inliningCss) {
      baseLoader = miniCssExtractPlugin.loader;
    }

    modifyConfig.module.rules.push({
      test: /\.(scss|sass)(\.erb)?$/i,
      use: [
        baseLoader,
        {
          loader: require.resolve("css-loader"),
          options: {
            sourceMap: true,
            importLoaders: 2
          }
        },
        {
          loader: "postcss-loader",
          options: {
            sourceMap: true,
            postcssOptions: {
              // eslint-disable-next-line no-undef
              config: path.resolve(__dirname, "../../../postcss.config.js")
            }
          }
        },
        {
          loader: sassLoaderPath
        }
      ]
    });
  }

  return modifyConfig;
}

// Since all modifiers are functions, we can use a reduce clause to apply all them
module.exports = (originalConfig) => [overrideSassRule].reduce((acc, modifier) => modifier(acc), originalConfig)
