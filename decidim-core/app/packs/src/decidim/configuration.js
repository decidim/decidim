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
    if (typeof key === "string" && key.length > 0) {
      let currentNode = this.config;
      for (const part of key.split(".")) {
        currentNode = currentNode[part];
        if (!currentNode) {
          return null;
        }
      }
      return currentNode;
    }
    return this.config[key];
  }
}
