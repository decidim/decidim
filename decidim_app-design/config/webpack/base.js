/* eslint-disable */

const { webpackConfig, merge } = require("@decidim/webpacker")
const customConfig = require("./custom")

module.exports = merge(webpackConfig, customConfig)
