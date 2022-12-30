import * as i18n from "./i18n";

const config = {
  messages: {
    foo: "Foo",
    bar: { baz: { biz: "Biz" } },
    test: {
      eeny: "Eeny",
      meeny: {
        miny: "Miny",
        moe: "Moe"
      },
      catch: { atiger: { by: { the: { toe: "Toe" } } } }
    }
  }
};

window.Decidim = {
  config: {
    get: (key) => config[key]
  }
};

describe("getMessages", () => {
  describe("with no key", () => {
    it("returns all the configured messages", () => {
      expect(i18n.getMessages()).toEqual(config.messages);
    });
  });

  describe("with a top-level key", () => {
    it("returns the configured messages for that key only", () => {
      expect(i18n.getMessages("bar")).toEqual(config.messages.bar);
    });
  });

  describe("with a sub key", () => {
    it("returns the configured messages for that sub key only", () => {
      expect(i18n.getMessages("test.catch.atiger")).toEqual(config.messages.test.catch.atiger);
    });
  });
});

describe("createDictionary", () => {
  it("creates the correct a directory with correct key names", () => {
    const dict = i18n.createDictionary(config.messages);
    expect(dict.foo).toEqual("Foo");
    expect(dict["bar.baz.biz"]).toEqual("Biz");
    expect(dict["test.eeny"]).toEqual("Eeny");
    expect(dict["test.meeny.miny"]).toEqual("Miny");
    expect(dict["test.meeny.moe"]).toEqual("Moe");
    expect(dict["test.catch.atiger.by.the.toe"]).toEqual("Toe");
  });
});

describe("getDictionary", () => {
  it("fetches the correct messages and returns a dictionary for them", () => {
    const dict = i18n.getDictionary("test");
    expect(dict.eeny).toEqual("Eeny");
    expect(dict["meeny.miny"]).toEqual("Miny");
    expect(dict["meeny.moe"]).toEqual("Moe");
    expect(dict["catch.atiger.by.the.toe"]).toEqual("Toe");
  });
});
