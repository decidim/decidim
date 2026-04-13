export default class Configuration {
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

  hydrate(elementId = "decidim-config") {
    const element = document.getElementById(elementId);
    if (!element) {
      return null;
    }

    try {
      const data = JSON.parse(element.textContent);
      if (data.config) {
        this.set(data.config);
      }
      return data;
    } catch (error) {
      console.error(`[Decidim] Failed to parse config from #${elementId}:`, error);
      return null;
    }
  }
}
