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

import { Application } from "@hotwired/stimulus"
import MentionController from "src/decidim/controllers/mention/controller";
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
  let application = null;
  let controller = null;

  beforeEach(() => {
    // Set up Stimulus application
    application = Application.start();
    application.register("mention", MentionController);

    // Reset all mocks
    jest.clearAllMocks();
    mockTribute.attach.mockClear();
    mockTribute.detach.mockClear();
    TributeMock.mockClear();

    // Create DOM elements for testing
    document.body.innerHTML = `
      <div class="mention-container">
        <input data-noresults="No users found" data-controller="mention" />
        <div class="tribute-container"></div>
      </div>
    `;

    mockElement = document.querySelector("[data-controller='mention']");

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
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(mockElement, "mention");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    controller.disconnect();
    document.body.innerHTML = "";
    jest.restoreAllMocks();
  });

  describe("constructor", () => {
    it("creates instance with default options", () => {
      expect(controller.element).toBe(mockElement);
      expect(controller.options.noDataFoundMessage).toBe("No users found");
      expect(controller.options.debounceDelay).toBe(250);
      expect(controller.options.menuItemLimit).toBe(5);
    });

    it("initializes component when not inside editor", () => {
      expect(controller.initialized).toBe(true);
      expect(TributeMock).toHaveBeenCalled();
      expect(mockTribute.attach).toHaveBeenCalledWith(mockElement);
    });

    it("does not initialize when inside editor", () => {
      const editorContainer = document.createElement("div");
      editorContainer.classList.add("editor");
      const editorElement = document.createElement("input");
      editorElement.setAttribute("data-controller", "mention");
      editorContainer.appendChild(editorElement);
      document.body.appendChild(editorContainer);

      // Wait for the controller to be connected
      return new Promise((resolve) => {
        setTimeout(() => {
          controller = application.getControllerForElementAndIdentifier(editorElement, "mention");

          expect(controller.initialized).toBe(false);
          // Since TributeMock should not be called, we can check that tribute is null
          expect(controller.tribute).toBeNull();

          resolve();
        }, 0);
      });
    });
  });

  describe("Tribute configuration", () => {
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
      elementWithoutMessage.setAttribute("data-controller", "mention");
      document.body.appendChild(elementWithoutMessage);

      return new Promise((resolve) => {
        setTimeout(() => {
          controller = application.getControllerForElementAndIdentifier(elementWithoutMessage, "mention");

          // Check that the tribute was created and the second call (index [1]) has the expected config
          const tributeConfig = TributeMock.mock.calls[1][0];
          expect(tributeConfig.noMatchTemplate).toEqual(expect.any(Function));

          // Clean up
          controller.disconnect();
          elementWithoutMessage.remove();
          resolve();
        }, 0);
      });
    });
  });

  describe("event handling", () => {
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
      isolatedElement.setAttribute("data-controller", "mention");
      document.body.appendChild(isolatedElement);

      return new Promise((resolve) => {
        setTimeout(() => {
          const isolatedController = application.getControllerForElementAndIdentifier(isolatedElement, "mention");

          const event = new Event("focusout");
          Reflect.defineProperty(event, "target", {
            value: isolatedElement,
            enumerable: true
          });

          // Test that dispatching the focusout event does not throw when parent is null
          expect(() => isolatedElement.dispatchEvent(event)).not.toThrow();

          // Clean up
          isolatedController.disconnect();
          isolatedElement.remove();
          resolve();
        }, 0);
      });
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
      isolatedElement.setAttribute("data-controller", "mention");
      document.body.appendChild(isolatedElement);

      return new Promise((resolve) => {
        setTimeout(() => {
          const isolatedController = application.getControllerForElementAndIdentifier(isolatedElement, "mention");

          const event = new Event("input");
          Reflect.defineProperty(event, "target", {
            value: isolatedElement,
            enumerable: true
          });

          // Test that dispatching the input event does not throw when parent is null
          expect(() => isolatedElement.dispatchEvent(event)).not.toThrow();

          // Clean up
          isolatedController.disconnect();
          isolatedElement.remove();
          resolve();
        }, 0);
      });
    });
  });

  describe("remote search", () => {
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

  describe("destroy", () => {
    it("cleans up resources properly", () => {
      controller.disconnect();

      expect(mockTribute.detach).toHaveBeenCalledWith(mockElement);
      expect(controller.tribute).toBeNull();
      expect(controller.initialized).toBe(false);
    });

    it("handles missing tribute gracefully", () => {
      controller.tribute = null;

      expect(() => controller.disconnect()).not.toThrow();
    });

    it("handles missing element gracefully", () => {
      expect(() => controller.disconnect()).not.toThrow();
    });
  });

  describe("debounce functionality", () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it("debounces function calls", () => {
      const mockCallback = jest.fn();
      const debouncedFunction = controller.debounce(mockCallback, 100);

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
      const debouncedFunction = controller.debounce(mockCallback, 100);

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
    it("adjusts tribute container when tribute is active", () => {
      const mockParent = document.createElement("div");
      const mockTributeContainer = document.createElement("div");
      mockTributeContainer.classList.add("tribute-container");
      mockTributeContainer.setAttribute("style", "position: absolute; top: 10px;");
      mockParent.appendChild(mockTributeContainer);

      mockTribute.current = { element: { parentNode: mockParent } };

      controller.adjustTributeContainer();

      expect(mockParent.classList.contains("is-active")).toBe(true);
      expect(mockTributeContainer.getAttribute("style")).toBeNull();
    });

    it("handles missing tribute current element", () => {
      mockTribute.current = null;

      expect(() => controller.adjustTributeContainer()).not.toThrow();
    });

    it("handles missing parent element", () => {
      mockTribute.current = { element: { parentNode: null } };

      expect(() => controller.adjustTributeContainer()).not.toThrow();
    });
  });

  describe("CSRF token handling", () => {
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
