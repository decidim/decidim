/* global jest */
/* eslint max-lines: ["error", 360] */
import { Application } from "@hotwired/stimulus"
import StickyButtonsController from "src/decidim/controllers/sticky_buttons/controller";

// Mock Tailwind CSS screens
jest.mock("tailwindcss/defaultTheme", () => ({
  screens: {
    sm: "640px",
    md: "768px",
    lg: "1024px",
    xl: "1280px",
    "2xl": "1536px"
  }
}));

describe("StickyButtonsController", () => {
  let mockFooter = null;
  let mockStickyButtons = null;
  let application = null;
  let controller = null;

  beforeEach(() => {
    application = Application.start();
    application.register("sticky-buttons", StickyButtonsController);
    // Reset DOM
    document.body.innerHTML = "";

    // Create mock footer element
    mockFooter = document.createElement("footer");
    mockFooter.style.marginBottom = "";

    // Create mock sticky buttons element
    mockStickyButtons = document.createElement("div");
    mockStickyButtons.setAttribute("data-controller", "sticky-buttons");
    Reflect.defineProperty(mockStickyButtons, "offsetHeight", {
      value: 80,
      writable: true
    });

    // Append elements to DOM
    document.body.appendChild(mockFooter);
    document.body.appendChild(mockStickyButtons);

    // Mock window.matchMedia
    window.matchMedia = jest.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: jest.fn(),
      removeListener: jest.fn(),
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
      dispatchEvent: jest.fn()
    }));

    // Spy on event listeners
    jest.spyOn(document, "addEventListener");
    jest.spyOn(window, "addEventListener");

    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(mockStickyButtons, "sticky-buttons");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
    document.body.innerHTML = "";
  });

  describe("constructor", () => {
    it("should initialize with correct DOM elements", () => {
      expect(controller).toBeDefined();
      expect(controller.element).toBe(mockStickyButtons);
    });

    it("should handle missing footer element", () => {
      mockFooter.remove();

      expect(controller).toBeDefined();

      controller.disconnect();
      controller.connect();

      expect(controller.footer).toBeNull();
      expect(controller.element).toBe(mockStickyButtons);
    });
  });

  describe("initialize", () => {
    it("should call adjustCtasButtons on initialization", () => {
      const adjustSpy = jest.spyOn(controller, "adjustCtasButtons");

      controller.disconnect();
      controller.connect();

      expect(adjustSpy).toHaveBeenCalledTimes(1);
    });

    it("should add scroll event listener", () => {
      controller.disconnect();
      controller.connect();

      expect(document.addEventListener).toHaveBeenCalledWith(
        "scroll",
        expect.any(Function)
      );
    });

    it("should add toggle event listener", () => {
      controller.disconnect();
      controller.connect();

      expect(document.addEventListener).toHaveBeenCalledWith(
        "on:toggle",
        expect.any(Function)
      );
    });

    it("should add resize event listener", () => {
      controller.disconnect();
      controller.connect();

      expect(window.addEventListener).toHaveBeenCalledWith(
        "resize",
        expect.any(Function)
      );
    });

    it("should call adjustCtasButtons on scroll event", () => {
      const adjustSpy = jest.spyOn(controller, "adjustCtasButtons");
      controller.disconnect();
      controller.connect();

      // Simulate scroll event
      const scrollHandler = document.addEventListener.mock.calls.find(
        (call) => call[0] === "scroll"
      )[1];
      scrollHandler();

      // Once on init, once on scroll
      expect(adjustSpy).toHaveBeenCalledTimes(2);
    });

    it("should call adjustCtasButtons on toggle event", () => {
      const adjustSpy = jest.spyOn(controller, "adjustCtasButtons");
      controller.disconnect();
      controller.connect();

      // Simulate toggle event
      const toggleHandler = document.addEventListener.mock.calls.find(
        (call) => call[0] === "on:toggle"
      )[1];
      toggleHandler();

      // Once on init, once on toggle
      expect(adjustSpy).toHaveBeenCalledTimes(2);
    });

    it("should call adjustCtasButtons on resize event", () => {
      const adjustSpy = jest.spyOn(controller, "adjustCtasButtons");
      controller.disconnect();
      controller.connect();

      // Simulate resize event
      const resizeHandler = window.addEventListener.mock.calls.find(
        (call) => call[0] === "resize"
      )[1];
      resizeHandler();

      // Once on init, once on resize
      expect(adjustSpy).toHaveBeenCalledTimes(2);
    });
  });

  describe("isScreenSize", () => {
    it("should return true when screen matches the breakpoint", () => {
      window.matchMedia.mockReturnValue({ matches: true });

      const result = controller.isScreenSize("md");

      expect(result).toBe(true);
      expect(window.matchMedia).toHaveBeenCalledWith("(min-width: 768px)");
    });

    it("should return false when screen does not match the breakpoint", () => {
      window.matchMedia.mockReturnValue({ matches: false });

      const result = controller.isScreenSize("md");

      expect(result).toBe(false);
      expect(window.matchMedia).toHaveBeenCalledWith("(min-width: 768px)");
    });

    it("should work with different screen size keys", () => {
      controller.isScreenSize("sm");
      expect(window.matchMedia).toHaveBeenCalledWith("(min-width: 640px)");

      controller.isScreenSize("lg");
      expect(window.matchMedia).toHaveBeenCalledWith("(min-width: 1024px)");

      controller.isScreenSize("xl");
      expect(window.matchMedia).toHaveBeenCalledWith("(min-width: 1280px)");

      controller.isScreenSize("2xl");
      expect(window.matchMedia).toHaveBeenCalledWith("(min-width: 1536px)");
    });
  });

  describe("adjustCtasButtons", () => {
    it("should return early if footer does not exist", () => {
      document.body.removeChild(mockFooter);

      controller.adjustCtasButtons();

      // No error should be thrown and no margin should be set
      expect(() => controller.adjustCtasButtons()).not.toThrow();
    });

    it("should set margin to 0 on medium screens and larger", () => {
      window.matchMedia.mockReturnValue({ matches: true });

      controller.adjustCtasButtons();

      expect(mockFooter.style.marginBottom).toBe("0px");
    });

    it("should set margin equal to sticky buttons height on smaller screens", () => {
      window.matchMedia.mockReturnValue({ matches: false });

      controller.adjustCtasButtons();

      expect(mockFooter.style.marginBottom).toBe("80px");
    });

    it("should handle different sticky button heights", () => {
      window.matchMedia.mockReturnValue({ matches: false });
      Reflect.defineProperty(mockStickyButtons, "offsetHeight", { value: 120 });

      controller.adjustCtasButtons();

      expect(mockFooter.style.marginBottom).toBe("120px");
    });

    it("should handle zero height sticky buttons", () => {
      window.matchMedia.mockReturnValue({ matches: false });
      Reflect.defineProperty(mockStickyButtons, "offsetHeight", { value: 0 });

      controller.adjustCtasButtons();

      expect(mockFooter.style.marginBottom).toBe("0px");
    });
  });

  describe("integration tests", () => {

    it("should properly initialize and handle responsive behavior", () => {
      // Start with mobile view
      window.matchMedia.mockReturnValue({ matches: false });
      expect(mockFooter.style.marginBottom).toBe("80px");

      // Switch to desktop view
      window.matchMedia.mockReturnValue({ matches: true });
      controller.adjustCtasButtons();
      expect(mockFooter.style.marginBottom).toBe("0px");

      // Switch back to mobile view
      window.matchMedia.mockReturnValue({ matches: false });
      controller.adjustCtasButtons();
      expect(mockFooter.style.marginBottom).toBe("80px");
    });

    it("should handle event-driven adjustments correctly", () => {
      window.matchMedia.mockReturnValue({ matches: false });
      // Simulate sticky button height change
      Reflect.defineProperty(mockStickyButtons, "offsetHeight", { value: 100 });

      // Trigger resize event
      const resizeHandler = window.addEventListener.mock.calls.find(
        (call) => call[0] === "resize"
      )[1];
      resizeHandler();

      expect(mockFooter.style.marginBottom).toBe("100px");
    });

    it("should gracefully handle missing elements during events", () => {
      // Remove footer after initialization
      mockFooter.remove();
      controller.footer = null;

      // Should not throw error when handling events
      const scrollHandler = document.addEventListener.mock.calls.find(
        (call) => call[0] === "scroll"
      )[1];

      expect(() => scrollHandler()).not.toThrow();
    });
  });

  describe("edge cases", () => {
    it("should handle DOM changes after initialization", () => {
      window.matchMedia.mockReturnValue({ matches: false });

      // Simulate dynamic content loading that changes button height
      Reflect.defineProperty(mockStickyButtons, "offsetHeight", { value: 150 });
      controller.adjustCtasButtons();

      expect(mockFooter.style.marginBottom).toBe("150px");
    });

    it("should work when sticky buttons are initially hidden", () => {
      Reflect.defineProperty(mockStickyButtons, "offsetHeight", { value: 0 });
      window.matchMedia.mockReturnValue({ matches: false });

      controller.adjustCtasButtons();

      expect(mockFooter.style.marginBottom).toBe("0px");
    });

    it("should handle multiple footer elements correctly", () => {
      // Add another footer to test selector specificity
      const secondFooter = document.createElement("footer");
      document.body.appendChild(secondFooter);

      // Should select the first footer element
      expect(controller.footer).toBe(mockFooter);
    });
  });
});
