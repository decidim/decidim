const sass = require("sass-embedded");
const url = require("url");
const path = require("path");
const { config: { additional_paths: loadPaths, stylesheet_imports: stylesheetImports  } } = require("shakapacker");

const decidimImporter = {
  canonicalize(importerUrl, options) {
    if (options.fromImport) {
      return null;
    }
    if (!importerUrl.startsWith("decidim:")) {
      return null;
    }
    return new URL(importerUrl);
  },
  load(canonicalUrl) {
    const matches = decodeURI(canonicalUrl.toString()).match(/^decidim:style-([^[]+)\[([^\]]+)\]$/);
    if (!matches) {
      return { contents: "@mixin styles {}", syntax: "scss" };
    }

    if (!stylesheetImports) {
      return { contents: "@mixin styles {}", syntax: "scss" };
    }

    const type = matches[1];
    const group = matches[2];
    if (!stylesheetImports[type] || !stylesheetImports[type][group]) {
      // If the group is not defined, return an empty configuration because
      // otherwise the importer would continue finding the asset through
      // paths which obviously fails.
      return { contents: "@mixin styles {}", syntax: "scss" };
    }

    const statements = stylesheetImports[type][group].map((style) => `@include meta.load-css("${style}");`);
    const contents = `
      @use "sass:meta";

      @mixin styles {
        ${statements.join("\n")}
      }
    `;

    return { contents, syntax: "scss" };
  }
};

/**
 * Custom loader for compiling Sass.
 *
 * @param {String} content The content to compile
 * @returns {void}
 */
module.exports = function(content) { // eslint-disable-line no-undef
  const callback = this.async();

  let result = null;

  try {
    result = sass.compileString(
      content,
      {
        loadPaths,
        importers: [decidimImporter],
        sourceMap: true,
        sourceMapIncludeSources: true,
        style: "expanded"
      }
    );
  } catch (error) {
    if (error.span && typeof error.span.url !== "undefined") {
      this.addDependency(url.fileURLToPath(error.span.url));
    }

    callback(error);

    return;
  }

  if (typeof result.loadedUrls !== "undefined") {
    result.loadedUrls.forEach((includedFile) => {
      if (includedFile.protocol !== "file:") {
        return;
      }
      const normalizedIncludedFile = url.fileURLToPath(includedFile);

      // Custom `importer` can return only `contents` so includedFile will be relative
      if (path.isAbsolute(normalizedIncludedFile)) {
        this.addDependency(normalizedIncludedFile);
      }
    });
  }

  callback(null, result.css.toString(), result.sourceMap);
};
