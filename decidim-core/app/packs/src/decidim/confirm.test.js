/* global jest */

jest.mock("src/decidim/refactor/moved/icon", () => () => "<svg></svg>");

describe("Confirm dialog for button[type='button']", () => {
  let mockRails = null;
  let mockDecidim = null;

  beforeEach(() => {
    jest.clearAllMocks();
    document.body.innerHTML = `
      <div id="confirm-modal" style="display: none;">
        <div data-dialog-title></div>
        <div class="confirm-modal-icon"></div>
        <div data-confirm-modal-content></div>
        <button data-confirm-ok>Confirm</button>
        <button data-confirm-cancel>Cancel</button>
      </div>
    `;

    mockRails = {
      linkClickSelector: "a[data-confirm]",
      buttonClickSelector: "button[data-confirm]:not([form])",
      formInputClickSelector: 'form button[type="submit"], form button:not([type])',
      inputChangeSelector: "input[data-confirm], select[data-confirm]",
      formSubmitSelector: "form[data-confirm]",
      stopEverything: jest.fn(),
      fire: jest.fn((el, event) => {
        const evt = new CustomEvent(event);
        el.dispatchEvent(evt);
        return true;
      }),
      matches: function(element, selector) {
        if (element instanceof Element) {
          return element.matches(selector);
        }
        return false;
      }
    };

    mockDecidim = {
      currentDialogs: {
        "confirm-modal": {
          open: jest.fn(),
          close: jest.fn()
        }
      }
    };

    window.Rails = mockRails;
    window.Decidim = mockDecidim;
  });

  afterEach(() => {
    document.body.innerHTML = "";
  });

  describe("selector matching for button[type='button'] with data-confirm", () => {
    it("matches button[data-confirm][type='button'] selector", () => {
      const button = document.createElement("button");
      button.type = "button";
      button.setAttribute("data-confirm", "Are you sure?");

      expect(button.matches('button[data-confirm][type="button"]')).toBe(true);
    });

    it("matches form button[data-confirm] selector", () => {
      const form = document.createElement("form");
      const button = document.createElement("button");
      button.setAttribute("data-confirm", "Are you sure?");
      form.appendChild(button);

      expect(button.matches("form button[data-confirm]")).toBe(true);
    });

    it("does not match regular button without data-confirm", () => {
      const button = document.createElement("button");
      button.type = "button";

      expect(button.matches('button[data-confirm][type="button"]')).toBe(false);
    });

    it("does not match button[type='submit'] with the type='button' selector", () => {
      const button = document.createElement("button");
      button.type = "submit";
      button.setAttribute("data-confirm", "Are you sure?");

      expect(button.matches('button[data-confirm][type="button"]')).toBe(false);
    });

    it("matches button[type='button'] inside form", () => {
      document.body.innerHTML = `
        <form>
          <button type="button" data-confirm="Test message">Click me</button>
        </form>
      `;

      const button = document.querySelector('button[type="button"]');
      expect(button.matches('button[data-confirm][type="button"]')).toBe(true);
      expect(button.matches("form button[data-confirm]")).toBe(true);
    });

    it("does not match button[type='button'] without data-confirm inside form", () => {
      document.body.innerHTML = `
        <form>
          <button type="button">Click me</button>
        </form>
      `;

      const button = document.querySelector('button[type="button"]');
      expect(button.matches('button[data-confirm][type="button"]')).toBe(false);
      expect(button.matches("form button[data-confirm]")).toBe(false);
    });
  });

  describe("initializeConfirm - selectors registration", () => {
    it("adds click event listener with proper selectors including button[type='button'] support", async () => {
      const { initializeConfirm } = await import("src/decidim/confirm.js");

      const addEventListenerSpy = jest.spyOn(document, "addEventListener");

      initializeConfirm();

      expect(addEventListenerSpy).toHaveBeenCalledWith("click", expect.any(Function));
    });

    it("adds change event listener for input change selector", async () => {
      const { initializeConfirm } = await import("src/decidim/confirm.js");

      const addEventListenerSpy = jest.spyOn(document, "addEventListener");

      initializeConfirm();

      const changeHandlerCalls = addEventListenerSpy.mock.calls.filter(
        (call) => call[0] === "change"
      );
      expect(changeHandlerCalls.length).toBeGreaterThan(0);
    });

    it("adds submit event listener for form submit selector", async () => {
      const { initializeConfirm } = await import("src/decidim/confirm.js");

      const addEventListenerSpy = jest.spyOn(document, "addEventListener");

      initializeConfirm();

      const submitHandlerCalls = addEventListenerSpy.mock.calls.filter(
        (call) => call[0] === "submit"
      );
      expect(submitHandlerCalls.length).toBeGreaterThan(0);
    });

    it("adds turbo:load event listener for Foundation Abide compatibility", async () => {
      const { initializeConfirm } = await import("src/decidim/confirm.js");

      const addEventListenerSpy = jest.spyOn(document, "addEventListener");

      initializeConfirm();

      const turboLoadCalls = addEventListenerSpy.mock.calls.filter(
        (call) => call[0] === "turbo:load"
      );
      expect(turboLoadCalls.length).toBeGreaterThan(0);
    });
  });

  describe("handleDocumentEvent with button[type='button'] support", () => {
    it("handles click on button[type='button'] with data-confirm and form attribute", async () => {
      const { initializeConfirm } = await import("src/decidim/confirm.js");

      document.body.innerHTML = `
        <form id="my-form">
          <button type="button" form="my-form" data-confirm="Are you sure?">Click me</button>
        </form>
      `;

      const button = document.querySelector('button[type="button"]');
      const openSpy = jest.spyOn(mockDecidim.currentDialogs["confirm-modal"], "open");

      initializeConfirm();

      button.click();

      expect(openSpy).toHaveBeenCalled();
    });

    it("handles click on button[type='button'] with data-confirm outside form", async () => {
      const { initializeConfirm } = await import("src/decidim/confirm.js");

      document.body.innerHTML = `
        <button type="button" data-confirm="Are you sure?">Click me</button>
      `;

      const button = document.querySelector('button[type="button"]');
      const openSpy = jest.spyOn(mockDecidim.currentDialogs["confirm-modal"], "open");

      initializeConfirm();

      button.click();

      expect(openSpy).toHaveBeenCalled();
    });

    it("does not trigger confirm for button without data-confirm attribute", async () => {
      const { initializeConfirm } = await import("src/decidim/confirm.js");

      document.body.innerHTML = `
        <form>
          <button type="button">Click me</button>
        </form>
      `;

      const button = document.querySelector('button[type="button"]');
      const openSpy = jest.spyOn(mockDecidim.currentDialogs["confirm-modal"], "open");

      initializeConfirm();

      button.click();

      expect(openSpy).not.toHaveBeenCalled();
    });
  });
});

/* dummy end */
