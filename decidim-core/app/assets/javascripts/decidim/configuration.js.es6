((exports) => {
  class Configuration {
    constructor() {
      this.config = {};
    }

    set(key, value = null) {
      if (typeof key === "object") {
        this.config = { ...this.config, ...key };
      } else {
        this.config[key] = value;
      }
    }

    get(key) {
      return this.config[key];
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.Configuration = Configuration;
  exports.Decidim.config = new Configuration();
})(window);
