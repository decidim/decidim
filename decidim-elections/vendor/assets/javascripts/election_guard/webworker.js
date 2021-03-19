/* eslint-disable prefer-const */
/* eslint-disable no-unused-vars */
/* eslint-disable no-var */
/* eslint-disable no-undef */
self.languagePluginUrl = "./";
importScripts("./pyodide.js");

var onmessage = function (e) {
  // eslint-disable-line no-unused-vars
  languagePluginLoader
    .then(() => {
      return self.pyodide.loadPackage("decidim-electionguard");
    })
    .then(() => {
      const data = e.data;
      const keys = Object.keys(data);
      for (let key of keys) {
        if (key !== "python") {
          self[key] = data[key];
        }
      }

      self.pyodide
        .runPythonAsync(data.python, () => {})
        .then((results) => {
          self.postMessage({ results });
        });
    });
};
