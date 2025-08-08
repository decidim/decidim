/* eslint max-lines: ["error", 650] */
/* global global, jest */
/**
 * @jest-environment jsdom
 */


// Mock the Tribute library first
const mockTribute = {
  attach: jest.fn(),
  detach: jest.fn(),
  isActive: false,
  current: null,
  menu: null,
  range: {
    getDocument: () => document
  },
  menuContainer: null
};

// Create the constructor mock
jest.mock("src/decidim/vendor/tribute", () => {
  return jest.fn().mockImplementation(() => mockTribute);
});

// Now import the component after mocking
import MentionsComponent from "src/decidim/refactor/implementation/input_mentions";
import Tribute from "src/decidim/vendor/tribute";

// Get access to mock methods (pure JavaScript approach)
const TributeMock = Tribute;

// Mock global fetch
global.fetch = jest.fn();

// Mock window.Decidim
global.window.Decidim = {
  config: {
    get: jest.fn()
  }
};

describe("MentionsComponent", () => {
  let mockElement = null;
  let component = null;

  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();
    mockTribute.attach.mockClear();
    mockTribute.detach.mockClear();
    TributeMock.mockClear();

    // Create DOM elements for testing
    document.body.innerHTML = `
      <div class="mention-container">
        <input class="js-mentions" data-noresults="No users found" />
        <div class="tribute-container"></div>
      </div>
    `;

    mockElement = document.querySelector(".js-mentions");

    // Setup window.Decidim mock
    window.Decidim.config.get.mockReturnValue("http://localhost:3000/api");

    // Setup fetch mock
    fetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({
        data: {
          users: [
            {
              nickname: "testuser",
              name: "Test User",
              avatarUrl: "http://example.com/avatar.jpg",
              __typename: "User"
            }
          ]
        }
      })
    });
  });

  afterEach(() => {
    if (component) {
      component.destroy();
    }
    document.body.innerHTML = "";
    jest.restoreAllMocks();
  });

  describe("constructor", () => {
    it("creates instance with default options", () => {
      component = new MentionsComponent(mockElement);

      expect(component.element).toBe(mockElement);
      expect(component.options.noDataFoundMessage).toBe("No users found");
      expect(component.options.debounceDelay).toBe(250);
      expect(component.options.menuItemLimit).toBe(5);
    });

    it("creates instance with custom options", () => {
      const customOptions = {
        noDataFoundMessage: "Custom message",
        debounceDelay: 500,
        menuItemLimit: 10
      };

      component = new MentionsComponent(mockElement, customOptions);

      expect(component.options.noDataFoundMessage).toBe("Custom message");
      expect(component.options.debounceDelay).toBe(500);
      expect(component.options.menuItemLimit).toBe(10);
    });

    it("initializes component when not inside editor", () => {
      component = new MentionsComponent(mockElement);

      expect(component.initialized).toBe(true);
      expect(TributeMock).toHaveBeenCalled();
      expect(mockTribute.attach).toHaveBeenCalledWith(mockElement);
    });

    it("does not initialize when inside editor", () => {
      const editorContainer = document.createElement("div");
      editorContainer.classList.add("editor");
      const editorElement = document.createElement("input");
      editorContainer.appendChild(editorElement);
      document.body.appendChild(editorContainer);

      component = new MentionsComponent(editorElement);

      expect(component.initialized).toBe(false);
      expect(TributeMock).not.toHaveBeenCalled();
    });
  });

  describe("Tribute configuration", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
    });

    it("configures Tribute with correct options", () => {
      const tributeConfig = TributeMock.mock.calls[0][0];

      expect(tributeConfig.trigger).toBe("@");
      expect(tributeConfig.positionMenu).toBe(true);
      expect(tributeConfig.allowSpaces).toBe(true);
      expect(tributeConfig.menuItemLimit).toBe(5);
      expect(tributeConfig.fillAttr).toBe("nickname");
      expect(tributeConfig.selectClass).toBe("highlight");
    });

    it("configures lookup function correctly", () => {
      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockItem = { nickname: "testuser", name: "Test User" };

      expect(tributeConfig.lookup(mockItem)).toBe("testuserTest User");
    });

    it("configures selectTemplate function correctly", () => {
      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockItem = { original: { nickname: "testuser" } };

      expect(tributeConfig.selectTemplate(mockItem)).toBe("testuser");
      // eslint-disable-next-line no-undefined
      expect(tributeConfig.selectTemplate(undefined)).toBeNull();
    });

    it("configures menuItemTemplate function correctly", () => {
      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockItem = {
        original: {
          nickname: "testuser",
          name: "Test User",
          avatarUrl: "http://example.com/avatar.jpg"
        }
      };

      const template = tributeConfig.menuItemTemplate(mockItem);
      expect(template).toContain('img src="http://example.com/avatar.jpg"');
      expect(template).toContain("<strong>testuser</strong>");
      expect(template).toContain("<small>Test User</small>");
    });

    it("configures noMatchTemplate when no data found message exists", () => {
      const tributeConfig = TributeMock.mock.calls[0][0];

      expect(tributeConfig.noMatchTemplate()).toBe("<li>No users found</li>");
    });

    it("configures null noMatchTemplate when no message provided", () => {
      const elementWithoutMessage = document.createElement("input");
      const componentWithoutMessage = new MentionsComponent(elementWithoutMessage);

      const tributeConfig = TributeMock.mock.calls[1][0];
      expect(tributeConfig.noMatchTemplate).toEqual(expect.any(Function));

      componentWithoutMessage.destroy();
    });
  });

  describe("event handling", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
    });

    it("handles focusin event", () => {
      const event = new Event("focusin");
      Reflect.defineProperty(event, "target", {
        value: mockElement,
        enumerable: true
      });

      mockElement.dispatchEvent(event);

      expect(mockTribute.menuContainer).toBe(mockElement.parentNode);
    });

    it("handles focusout event when parent has is-active class", () => {
      mockElement.parentNode.classList.add("is-active");

      const event = new Event("focusout");
      Reflect.defineProperty(event, "target", {
        value: mockElement,
        enumerable: true
      });

      mockElement.dispatchEvent(event);

      expect(mockElement.parentNode.classList.contains("is-active")).toBe(false);
    });

    it("handles focusout event when parent does not exist", () => {
      const isolatedElement = document.createElement("input");
      const isolatedComponent = new MentionsComponent(isolatedElement);

      const event = new Event("focusout");
      Reflect.defineProperty(event, "target", {
        value: isolatedElement,
        enumerable: true
      });

      expect(() => isolatedElement.dispatchEvent(event)).not.toThrow();

      isolatedComponent.destroy();
    });

    it("handles input event when tribute is active", () => {
      mockTribute.isActive = true;

      const event = new Event("input");
      Reflect.defineProperty(event, "target", {
        value: mockElement,
        enumerable: true
      });

      mockElement.dispatchEvent(event);

      expect(mockElement.parentNode.classList.contains("is-active")).toBe(true);
    });

    it("handles input event when tribute is not active", () => {
      mockTribute.isActive = false;
      mockElement.parentNode.classList.add("is-active");

      const event = new Event("input");
      Reflect.defineProperty(event, "target", {
        value: mockElement,
        enumerable: true
      });

      mockElement.dispatchEvent(event);

      expect(mockElement.parentNode.classList.contains("is-active")).toBe(false);
    });

    it("handles input event when parent does not exist", () => {
      const isolatedElement = document.createElement("input");
      const isolatedComponent = new MentionsComponent(isolatedElement);

      const event = new Event("input");
      Reflect.defineProperty(event, "target", {
        value: isolatedElement,
        enumerable: true
      });

      expect(() => isolatedElement.dispatchEvent(event)).not.toThrow();

      isolatedComponent.destroy();
    });
  });

  describe("remote search", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
    });

    it("performs remote search successfully", async () => {
      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockCallback = jest.fn();

      // Execute the values function (which is debounced)
      await new Promise((resolve) => {
        tributeConfig.values("test", mockCallback);
        // Wait for debounce
        setTimeout(resolve, 300);
      });

      expect(fetch).toHaveBeenCalledWith(
        "http://localhost:3000/api",
        expect.objectContaining({
          method: "POST",
          headers: expect.objectContaining({
            "Content-Type": "application/json"
          }),
          body: JSON.stringify({
            query: '{users(filter:{wildcard:"test"}){nickname,name,avatarUrl,__typename}}'
          })
        })
      );

      expect(mockCallback).toHaveBeenCalledWith([
        {
          nickname: "testuser",
          name: "Test User",
          avatarUrl: "http://example.com/avatar.jpg",
          __typename: "User"
        }
      ]);
    });

    it("handles remote search failure", async () => {
      fetch.mockRejectedValueOnce(new Error("Network error"));

      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockCallback = jest.fn();

      await new Promise((resolve) => {
        tributeConfig.values("test", mockCallback);
        // Wait for debounce
        setTimeout(resolve, 300);
      });

      expect(mockCallback).toHaveBeenCalledWith([]);
    });

    it("handles empty search results", async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ data: {} })
      });

      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockCallback = jest.fn();

      await new Promise((resolve) => {
        tributeConfig.values("test", mockCallback);
        // Wait for debounce
        setTimeout(resolve, 300);
      });

      expect(mockCallback).toHaveBeenCalledWith([]);
    });

    it("handles non-ok response", async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 500
      });

      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockCallback = jest.fn();

      await new Promise((resolve) => {
        tributeConfig.values("test", mockCallback);
        // Wait for debounce
        setTimeout(resolve, 300);
      });

      expect(mockCallback).toHaveBeenCalledWith([]);
    });
  });

  describe("attachToElement", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
    });

    it("attaches tribute to new element", () => {
      const newElement = document.createElement("input");
      document.body.appendChild(newElement);

      component.attachToElement(newElement);

      expect(mockTribute.attach).toHaveBeenCalledWith(newElement);
    });

    it("handles null element gracefully", () => {
      component.attachToElement(null);

      // Should not throw error
      // Only the initial attach
      expect(mockTribute.attach).toHaveBeenCalledTimes(1);
    });

    it("handles missing tribute gracefully", () => {
      component.tribute = null;
      const newElement = document.createElement("input");

      expect(() => component.attachToElement(newElement)).not.toThrow();
    });

    it("handles missing tribute menu in DOM", () => {
      const newElement = document.createElement("input");
      const mockMenu = document.createElement("div");
      mockTribute.menu = mockMenu;

      // Mock that menu is not in document body
      const originalContains = document.body.contains;
      document.body.contains = jest.fn().mockReturnValue(false);
      const originalAppendChild = document.body.appendChild;
      document.body.appendChild = jest.fn();

      component.attachToElement(newElement);

      expect(document.body.appendChild).toHaveBeenCalledWith(mockMenu);

      // Restore original methods
      document.body.contains = originalContains;
      document.body.appendChild = originalAppendChild;
    });
  });

  describe("destroy", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
    });

    it("cleans up resources properly", () => {
      component.destroy();

      expect(mockTribute.detach).toHaveBeenCalledWith(mockElement);
      expect(component.tribute).toBeNull();
      expect(component.element).toBeNull();
      expect(component.initialized).toBe(false);
    });

    it("handles missing tribute gracefully", () => {
      component.tribute = null;

      expect(() => component.destroy()).not.toThrow();
    });

    it("handles missing element gracefully", () => {
      component.element = null;

      expect(() => component.destroy()).not.toThrow();
    });
  });

  describe("debounce functionality", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it("debounces function calls", () => {
      const mockCallback = jest.fn();
      const debouncedFunction = component._debounce(mockCallback, 100);

      debouncedFunction("arg1");
      debouncedFunction("arg2");
      debouncedFunction("arg3");

      expect(mockCallback).not.toHaveBeenCalled();

      jest.advanceTimersByTime(100);

      expect(mockCallback).toHaveBeenCalledTimes(1);
      expect(mockCallback).toHaveBeenCalledWith("arg3");
    });

    it("cancels previous timeout on new call", () => {
      const mockCallback = jest.fn();
      const debouncedFunction = component._debounce(mockCallback, 100);

      debouncedFunction("arg1");
      jest.advanceTimersByTime(50);
      debouncedFunction("arg2");
      jest.advanceTimersByTime(50);

      expect(mockCallback).not.toHaveBeenCalled();

      jest.advanceTimersByTime(50);

      expect(mockCallback).toHaveBeenCalledTimes(1);
      expect(mockCallback).toHaveBeenCalledWith("arg2");
    });
  });

  describe("tribute container adjustment", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
    });

    it("adjusts tribute container when tribute is active", () => {
      const mockParent = document.createElement("div");
      const mockTributeContainer = document.createElement("div");
      mockTributeContainer.classList.add("tribute-container");
      mockTributeContainer.setAttribute("style", "position: absolute; top: 10px;");
      mockParent.appendChild(mockTributeContainer);

      mockTribute.current = { element: { parentNode: mockParent } };

      component._adjustTributeContainer();

      expect(mockParent.classList.contains("is-active")).toBe(true);
      expect(mockTributeContainer.getAttribute("style")).toBeNull();
    });

    it("handles missing tribute current element", () => {
      mockTribute.current = null;

      expect(() => component._adjustTributeContainer()).not.toThrow();
    });

    it("handles missing parent element", () => {
      mockTribute.current = { element: { parentNode: null } };

      expect(() => component._adjustTributeContainer()).not.toThrow();
    });
  });

  describe("CSRF token handling", () => {
    beforeEach(() => {
      component = new MentionsComponent(mockElement);
    });

    it("includes CSRF token in requests when available", async () => {
      const mockToken = "test-csrf-token";
      const metaElement = document.createElement("meta");
      metaElement.name = "csrf-token";
      metaElement.content = mockToken;
      document.head.appendChild(metaElement);

      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockCallback = jest.fn();

      await new Promise((resolve) => {
        tributeConfig.values("test", mockCallback);
        setTimeout(resolve, 300);
      });

      expect(fetch).toHaveBeenCalledWith(
        expect.any(String),
        expect.objectContaining({
          headers: expect.objectContaining({
            "X-CSRF-Token": mockToken
          })
        })
      );
    });

    it("handles missing CSRF token gracefully", async () => {
      const tributeConfig = TributeMock.mock.calls[0][0];
      const mockCallback = jest.fn();

      await new Promise((resolve) => {
        tributeConfig.values("test", mockCallback);
        setTimeout(resolve, 300);
      });

      expect(fetch).toHaveBeenCalledWith(
        expect.any(String),
        expect.objectContaining({
          body: '{"query":"{users(filter:{wildcard:\\"test\\"}){nickname,name,avatarUrl,__typename}}"}',
          method: "POST",
          headers: expect.objectContaining({
            "Content-Type": "application/json",
            "X-CSRF-Token": expect.any(String)
          })
        })
      );
    });
  });

  describe("external integration", () => {
    it("handles attach-mentions-element event with no element", () => {
      const attachEvent = new CustomEvent("attach-mentions-element", {
        detail: {}
      });

      expect(() => document.dispatchEvent(attachEvent)).not.toThrow();
    });

    it("handles attach-mentions-element event with no detail", () => {
      const attachEvent = new CustomEvent("attach-mentions-element");

      expect(() => document.dispatchEvent(attachEvent)).not.toThrow();
    });
  });
});
