/* eslint id-length: ["error", { "exceptions": ["d"] }] */

const fs = require("fs");
const path = require("path");

const root = __dirname;
const moduleDirs = ["node_modules"];

// Add any decidim-*/app/packs directories found in the root
fs.readdirSync(root, { withFileTypes: true }).
  filter((d) => d.isDirectory() && (/^decidim-(.*)$/).test(d.name)).
  forEach((d) => moduleDirs.push(path.join("<rootDir>", d.name, "app/packs")));

module.exports = {
  testEnvironment: "jsdom",
  testEnvironmentOptions: {
    "url": "https://decidim.dev/"
  },
  setupFiles: [
    "<rootDir>/decidim-core/spec/js/entry_test.js",
    "raf/polyfill"
  ],
  moduleFileExtensions: [
    "js"
  ],
  moduleNameMapper: {
    "\\.(scss|css|less)$": "identity-obj-proxy"
  },
  transform: {
    "\\.yml$": "yaml-jest",
    "\\.js$": "babel-jest"
  },
  testRegex: "\\.(test|spec)\\.js$",
  moduleDirectories: moduleDirs
};
