/* eslint max-lines: ["error", 320] */
/* global jest */

import { Application } from "@hotwired/stimulus"
import StickyHeaderController from "src/decidim/controllers/sticky_header/controller";

// Mock Tailwind CSS screens
jest.mock("tailwindcss/defaultTheme", () => ({
  screens: {
    md: "768px",
    lg: "1024px",
    xl: "1280px"
  }
}));

describe("StickyHeader", () => {
  let mockStickyHeaderElement = null;
  let mockMenuBarContainer = null;
  let mockMainBar = null;
  let application = null;
  let controller = null;

  beforeEach(() => {
    application = Application.start();
    application.register("sticky-header", StickyHeaderController);
    // Reset DOM
    document.body.innerHTML = "";

    // Create mock elements
    mockStickyHeaderElement = document.createElement("div");
    mockStickyHeaderElement.setAttribute("data-controller", "sticky-header");
    mockStickyHeaderElement.style.position = "fixed";
    Reflect.defineProperty(mockStickyHeaderElement, "offsetHeight", {
      value: 60,
      writable: true
    });

    mockMenuBarContainer = document.createElement("div");
    mockMenuBarContainer.id = "menu-bar-container";

    mockMainBar = document.createElement("div");
    mockMainBar.id = "main-bar";
    Reflect.defineProperty(mockMainBar, "offsetParent", {
      value: mockMainBar,
      writable: true
    });

    // Append elements to DOM
    document.body.appendChild(mockStickyHeaderElement);
    document.body.appendChild(mockMenuBarContainer);
    document.body.appendChild(mockMainBar);

    // Mock window properties
    Reflect.defineProperty(window, "scrollY", {
      value: 0,
      writable: true
    });

    // Mock window.matchMedia
    window.matchMedia = jest.fn().mockImplementation((query) => ({
      matches: Boolean(query.includes("768px")),
      media: query,
      onchange: null,
      addListener: jest.fn(),
      removeListener: jest.fn(),
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
      dispatchEvent: jest.fn()
    }));

    // Mock getComputedStyle
    window.getComputedStyle = jest.fn().mockReturnValue({
      position: "fixed"
    });

    // Spy on event listeners
    jest.spyOn(document, "addEventListener");
    jest.spyOn(window, "addEventListener");

    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(mockStickyHeaderElement, "sticky-header");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
    document.body.innerHTML = "";
  });

  describe("connect", () => {
    it("should initialize with correct default values", () => {
      window.scrollY = 100;

      controller.disconnect();
      controller.connect();

      expect(controller.prevScroll).toBe(100);
      expect(controller.element).toBe(mockStickyHeaderElement);
    });

    it("should call all setup methods", () => {
      const fixMarginSpy = jest.spyOn(controller, "fixMenuBarContainerMargin");
      const setupListenersSpy = jest.spyOn(controller, "setupEventListeners");
      const setupScrollSpy = jest.spyOn(controller, "setupScrollHandler");

      controller.disconnect();
      controller.connect();

      expect(fixMarginSpy).toHaveBeenCalled();
      expect(setupListenersSpy).toHaveBeenCalled();
      expect(setupScrollSpy).toHaveBeenCalled();
    });
  });

  describe("isMaxScreenSize", () => {
    it("should return true for screens at or below breakpoint", () => {
      window.matchMedia.mockReturnValue({ matches: true });

      const result = controller.isMaxScreenSize("md");

      expect(result).toBe(true);
      expect(window.matchMedia).toHaveBeenCalledWith("(max-width: 768px)");
    });

    it("should return false for screens above breakpoint", () => {
      window.matchMedia.mockReturnValue({ matches: false });

      const result = controller.isMaxScreenSize("md");

      expect(result).toBe(false);
    });

    it("should handle different breakpoint keys", () => {
      controller.isMaxScreenSize("lg");
      expect(window.matchMedia).toHaveBeenCalledWith("(max-width: 1024px)");
    });
  });

  describe("fixMenuBarContainerMargin", () => {

    it("should set margin on mobile devices", () => {
      window.matchMedia.mockReturnValue({ matches: true });

      controller.fixMenuBarContainerMargin();

      expect(mockMenuBarContainer.style.marginTop).toBe("60px");
    });

    it("should not set margin on desktop devices", () => {
      window.matchMedia.mockReturnValue({ matches: false });

      controller.fixMenuBarContainerMargin();

      expect(mockMenuBarContainer.style.marginTop).toBe("0px");
    });

    it("should handle missing menu bar container", () => {
      mockMenuBarContainer.remove();

      expect(() => controller.fixMenuBarContainerMargin()).not.toThrow();
    });
  });

  describe("setupEventListeners", () => {
    it("should add resize event listener", () => {
      controller.setupEventListeners();

      expect(window.addEventListener).toHaveBeenCalledWith(
        "resize",
        expect.any(Function)
      );
    });

    it("should call fixMenuBarContainerMargin on resize", () => {
      const fixMarginSpy = jest.spyOn(controller, "fixMenuBarContainerMargin");
      controller.setupEventListeners();

      // Simulate resize event
      const resizeHandler = window.addEventListener.mock.calls.find(
        (call) => call[0] === "resize"
      )[1];
      resizeHandler();

      expect(fixMarginSpy).toHaveBeenCalled();
    });
  });

  describe("setupScrollHandler", () => {
    it("should add scroll event listener when sticky header exists", () => {
      controller.setupScrollHandler();

      expect(document.addEventListener).toHaveBeenCalledWith(
        "scroll",
        expect.any(Function)
      );
    });

    it("should call handleScroll on scroll event", () => {
      const handleScrollSpy = jest.spyOn(controller, "handleScroll");
      controller.setupScrollHandler();

      // Simulate scroll event
      const scrollHandler = document.addEventListener.mock.calls.find(
        (call) => call[0] === "scroll"
      )[1];
      scrollHandler();

      expect(handleScrollSpy).toHaveBeenCalled();
    });
  });

  describe("handleScroll", () => {
    beforeEach(() => {
      controller.prevScroll = 0;
    });

    it("should call fixMenuBarContainerMargin", () => {
      const fixMarginSpy = jest.spyOn(controller, "fixMenuBarContainerMargin");

      controller.handleScroll();

      expect(fixMarginSpy).toHaveBeenCalled();
    });

    it("should return early if main bar has no offsetParent", () => {
      Reflect.defineProperty(mockMainBar, "offsetParent", { value: null });

      controller.handleScroll();

      expect(mockStickyHeaderElement.style.top).toBe("");
    });

    it("should return early if sticky header is not fixed", () => {
      window.getComputedStyle.mockReturnValue({ position: "static" });

      controller.handleScroll();

      expect(mockStickyHeaderElement.style.top).toBe("");
    });

    it("should show header when scrolling up", () => {
      window.scrollY = 50;
      controller.prevScroll = 100;

      controller.handleScroll();

      expect(mockStickyHeaderElement.style.top).toBe("0px");
      expect(controller.prevScroll).toBe(50);
    });

    it("should hide header when scrolling down", () => {
      window.scrollY = 150;
      controller.prevScroll = 100;

      controller.handleScroll();

      expect(mockStickyHeaderElement.style.top).toBe("-60px");
      expect(controller.prevScroll).toBe(150);
    });

    it("should show header when near top of page", () => {
      // Less than offsetHeight (60)
      window.scrollY = 30;
      controller.prevScroll = 100;

      controller.handleScroll();

      expect(mockStickyHeaderElement.style.top).toBe("0px");
    });

    it("should not change header position for small scroll changes", () => {
      // Change of 3 pixels (less than threshold of 5)
      window.scrollY = 103;
      controller.prevScroll = 100;

      controller.handleScroll();

      expect(mockStickyHeaderElement.style.top).toBe("");
      // Should not update
      expect(controller.prevScroll).toBe(100);
    });

    it("should handle missing main bar element", () => {
      mockMainBar.remove();

      expect(() => controller.handleScroll()).not.toThrow();
    });
  });

  describe("integration tests", () => {
    it("should properly initialize and handle scroll events", () => {
      // Simulate scrolling down
      window.scrollY = 200;
      controller.handleScroll();
      expect(mockStickyHeaderElement.style.top).toBe("-60px");

      // Simulate scrolling up
      window.scrollY = 100;
      controller.handleScroll();
      expect(mockStickyHeaderElement.style.top).toBe("0px");
    });

    it("should handle responsive behavior correctly", () => {
      // Mobile view
      window.matchMedia.mockReturnValue({ matches: true });
      controller.disconnect();
      controller.connect();
      expect(mockMenuBarContainer.style.marginTop).toBe("60px");

      // Desktop view
      window.matchMedia.mockReturnValue({ matches: false });
      controller.fixMenuBarContainerMargin();
      expect(mockMenuBarContainer.style.marginTop).toBe("0px");
    });
  });
});
