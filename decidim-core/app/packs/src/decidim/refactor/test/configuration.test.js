/* eslint max-lines: ["error", 370] */
/**
 * @jest-environment jsdom
 */

import Configuration from "src/decidim/refactor/implementation/configuration";

describe("Configuration", () => {
  let config = null;

  beforeEach(() => {
    config = new Configuration();
  });

  describe("constructor", () => {
    it("initializes with empty config object", () => {
      expect(config.config).toEqual({});
    });
  });

  describe("set method", () => {
    describe("when setting individual key-value pairs", () => {
      it("sets a string value", () => {
        config.set("apiUrl", "https://example.com/api");
        expect(config.config.apiUrl).toBe("https://example.com/api");
      });

      it("sets a number value", () => {
        config.set("maxItems", 10);
        expect(config.config.maxItems).toBe(10);
      });

      it("sets a boolean value", () => {
        config.set("enableDebug", true);
        expect(config.config.enableDebug).toBe(true);
      });

      it("sets an object value", () => {
        const objectValue = { name: "Test", age: 25 };
        config.set("userInfo", objectValue);
        expect(config.config.userInfo).toEqual(objectValue);
      });

      it("sets an array value", () => {
        const arrayValue = ["item1", "item2", "item3"];
        config.set("items", arrayValue);
        expect(config.config.items).toEqual(arrayValue);
      });

      it("sets null value explicitly", () => {
        config.set("nullValue", null);
        expect(config.config.nullValue).toBeNull();
      });

      it("sets undefined value when no value provided", () => {
        config.set("undefinedValue");
        expect(config.config.undefinedValue).toBeNull();
      });

      it("overwrites existing values", () => {
        config.set("key", "oldValue");
        config.set("key", "newValue");
        expect(config.config.key).toBe("newValue");
      });
    });

    describe("when setting multiple key-value pairs with object", () => {
      it("merges object properties into config", () => {
        const settings = {
          apiUrl: "https://api.example.com",
          timeout: 5000,
          retries: 3
        };

        config.set(settings);

        expect(config.config).toEqual(settings);
      });

      it("merges with existing config without overwriting unrelated keys", () => {
        config.set("existingKey", "existingValue");

        const newSettings = {
          newKey1: "value1",
          newKey2: "value2"
        };

        config.set(newSettings);

        expect(config.config).toEqual({
          existingKey: "existingValue",
          newKey1: "value1",
          newKey2: "value2"
        });
      });

      it("overwrites existing keys when merging objects", () => {
        config.set("sharedKey", "oldValue");
        config.set("otherKey", "otherValue");

        const newSettings = {
          sharedKey: "newValue",
          additionalKey: "additionalValue"
        };

        config.set(newSettings);

        expect(config.config).toEqual({
          sharedKey: "newValue",
          otherKey: "otherValue",
          additionalKey: "additionalValue"
        });
      });

      it("handles nested objects correctly", () => {
        const nestedSettings = {
          database: {
            host: "localhost",
            port: 5432,
            credentials: {
              username: "admin",
              password: "secret"
            }
          },
          cache: {
            enabled: true,
            ttl: 3600
          }
        };

        config.set(nestedSettings);

        expect(config.config).toEqual(nestedSettings);
      });

      it("handles empty object", () => {
        config.set("existingKey", "existingValue");
        config.set({});

        expect(config.config).toEqual({
          existingKey: "existingValue"
        });
      });
    });

    describe("edge cases", () => {
      it("handles setting with empty string key", () => {
        config.set("", "emptyStringKey");
        expect(config.config[""]).toBe("emptyStringKey");
      });

      it("handles setting with numeric string key", () => {
        config.set("123", "numericStringKey");
        expect(config.config["123"]).toBe("numericStringKey");
      });

      it("handles setting with special character keys", () => {
        config.set("key-with-dashes", "dashValue");
        config.set("key_with_underscores", "underscoreValue");
        config.set("key.with.dots", "dotValue");

        expect(config.config["key-with-dashes"]).toBe("dashValue");
        expect(config.config.key_with_underscores).toBe("underscoreValue");
        expect(config.config["key.with.dots"]).toBe("dotValue");
      });
    });
  });

  describe("get method", () => {
    beforeEach(() => {
      config.set({
        stringValue: "test string",
        numberValue: 42,
        booleanValue: true,
        nullValue: null,
        objectValue: { nested: "value" },
        arrayValue: [1, 2, 3]
      });
    });

    it("retrieves existing string value", () => {
      expect(config.get("stringValue")).toBe("test string");
    });

    it("retrieves existing number value", () => {
      expect(config.get("numberValue")).toBe(42);
    });

    it("retrieves existing boolean value", () => {
      expect(config.get("booleanValue")).toBe(true);
    });

    it("retrieves existing null value", () => {
      expect(config.get("nullValue")).toBeNull();
    });

    it("retrieves existing object value", () => {
      expect(config.get("objectValue")).toEqual({ nested: "value" });
    });

    it("retrieves existing array value", () => {
      expect(config.get("arrayValue")).toEqual([1, 2, 3]);
    });

    it("returns undefined for nonexistent keys", () => {
      expect(config.get("nonExistentKey")).toBeUndefined();
    });

    it("handles empty string key", () => {
      config.set("", "emptyKeyValue");
      expect(config.get("")).toBe("emptyKeyValue");
    });

    it("handles special character keys", () => {
      config.set("key-with-special@chars!", "specialValue");
      expect(config.get("key-with-special@chars!")).toBe("specialValue");
    });
  });

  describe("integration scenarios", () => {
    it("handles typical configuration workflow", () => {
      // Initial setup
      config.set({
        apiUrl: "https://api.example.com",
        timeout: 5000,
        debug: false
      });

      // Verify initial state
      expect(config.get("apiUrl")).toBe("https://api.example.com");
      expect(config.get("timeout")).toBe(5000);
      expect(config.get("debug")).toBe(false);

      // Update individual setting
      config.set("debug", true);
      expect(config.get("debug")).toBe(true);

      // Add new settings
      config.set({
        retries: 3,
        cache: { enabled: true, ttl: 300 }
      });

      // Verify all settings
      expect(config.get("apiUrl")).toBe("https://api.example.com");
      expect(config.get("timeout")).toBe(5000);
      expect(config.get("debug")).toBe(true);
      expect(config.get("retries")).toBe(3);
      expect(config.get("cache")).toEqual({ enabled: true, ttl: 300 });
    });

    it("maintains object references correctly", () => {
      const originalObject = { key: "value" };
      config.set("reference", originalObject);

      const retrievedObject = config.get("reference");
      expect(retrievedObject).toBe(originalObject);
      expect(retrievedObject).toEqual({ key: "value" });

      // Modifying the original object should affect the stored reference
      originalObject.key = "modified";
      expect(config.get("reference").key).toBe("modified");
    });

    it("handles complex nested configuration", () => {
      const complexConfig = {
        server: {
          host: "localhost",
          port: 3000,
          ssl: {
            enabled: true,
            cert: "/path/to/cert",
            key: "/path/to/key"
          }
        },
        database: {
          connections: {
            primary: {
              host: "db1.example.com",
              port: 5432
            },
            replica: {
              host: "db2.example.com",
              port: 5432
            }
          }
        },
        features: ["auth", "cache", "logging"]
      };

      config.set(complexConfig);

      expect(config.get("server")).toEqual(complexConfig.server);
      expect(config.get("database")).toEqual(complexConfig.database);
      expect(config.get("features")).toEqual(complexConfig.features);
    });

    it("handles multiple Configuration instances independently", () => {
      const config1 = new Configuration();
      const config2 = new Configuration();

      config1.set("shared", "value1");
      config2.set("shared", "value2");

      expect(config1.get("shared")).toBe("value1");
      expect(config2.get("shared")).toBe("value2");

      config1.set({ additional: "config1" });
      config2.set({ additional: "config2" });

      expect(config1.get("additional")).toBe("config1");
      expect(config2.get("additional")).toBe("config2");
      expect(config1.get("shared")).toBe("value1");
      expect(config2.get("shared")).toBe("value2");
    });
  });

  describe("type validation", () => {
    it("accepts various types as keys when using object syntax", () => {
      // Note: Object keys are always converted to strings in JavaScript
      const mixedKeysObject = {
        123: "numeric key",
        "string": "string key",
        // This becomes "true" as a string key
        true: "boolean key"
      };

      config.set(mixedKeysObject);

      expect(config.get("123")).toBe("numeric key");
      expect(config.get("string")).toBe("string key");
      expect(config.get("true")).toBe("boolean key");
    });

    it("preserves value types correctly", () => {
      const values = {
        stringVal: "string",
        numberVal: 123,
        booleanVal: true,
        nullVal: null,
        // eslint-disable-next-line no-undefined
        undefinedVal: undefined,
        objectVal: {},
        arrayVal: [],
        functionVal: () => "test"
      };

      config.set(values);

      expect(typeof config.get("stringVal")).toBe("string");
      expect(typeof config.get("numberVal")).toBe("number");
      expect(typeof config.get("booleanVal")).toBe("boolean");
      expect(config.get("nullVal")).toBeNull();
      expect(config.get("undefinedVal")).toBeUndefined();
      expect(typeof config.get("objectVal")).toBe("object");
      expect(Array.isArray(config.get("arrayVal"))).toBe(true);
      expect(typeof config.get("functionVal")).toBe("function");
    });
  });
});
