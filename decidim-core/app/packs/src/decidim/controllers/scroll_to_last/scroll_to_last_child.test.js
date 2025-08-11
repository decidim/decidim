/* global global, jest */
import { Application } from "@hotwired/stimulus"
import ScrollToLastController from "src/decidim/controllers/scroll_to_last/controller";

describe("scrollToLastChild", () => {
  let mockContainer = null;
  let application = null;
  let controller = null;

  beforeEach(() => {
    // Set up Stimulus application
    application = Application.start();
    application.register("scroll-to-last", ScrollToLastController);
    // Reset DOM
    document.body.innerHTML = "";

    // Mock window.scrollTo
    global.window.scrollTo = jest.fn();

    // Create mock container element
    mockContainer = document.createElement("div");
    mockContainer.setAttribute("data-controller", "scroll-to-last");
    document.body.appendChild(mockContainer);

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(mockContainer, "scroll-to-last");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    jest.restoreAllMocks();
    global.window.scrollTo.mockClear();
  });

  describe("when called with no arguments", () => {
    it("should use document as default node", () => {
      const child1 = document.createElement("div");
      const child2 = document.createElement("div");
      const child3 = document.createElement("div");
      // Mock offsetTop property for the last child
      Reflect.defineProperty(child3, "offsetTop", {
        value: 500,
        writable: false
      });

      mockContainer.appendChild(child1);
      mockContainer.appendChild(child2);
      mockContainer.appendChild(child3);

      controller.disconnect();
      controller.connect();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 500,
        behavior: "smooth"
      });
    });
  });

  describe("when element with data-scroll-last-child exists", () => {
    it("should scroll to the last child when children exist", () => {
      const child1 = document.createElement("div");
      const child2 = document.createElement("div");
      const child3 = document.createElement("div");

      // Mock offsetTop property for the last child
      Reflect.defineProperty(child3, "offsetTop", {
        value: 250,
        writable: false
      });

      mockContainer.appendChild(child1);
      mockContainer.appendChild(child2);
      mockContainer.appendChild(child3);

      controller.disconnect();
      controller.connect();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 250,
        behavior: "smooth"
      });
    });

    it("should not scroll when no children exist", () => {
      controller.disconnect();
      controller.connect();
      expect(global.window.scrollTo).not.toHaveBeenCalled();
    });

    it("should scroll to the correct last child with multiple elements", () => {
      const message1 = document.createElement("div");
      message1.className = "message";

      const message2 = document.createElement("div");
      message2.className = "message";

      const message3 = document.createElement("div");
      message3.className = "message";

      // Mock offsetTop for the last message
      Reflect.defineProperty(message3, "offsetTop", {
        value: 750,
        writable: false
      });

      mockContainer.appendChild(message1);
      mockContainer.appendChild(message2);
      mockContainer.appendChild(message3);

      controller.disconnect();
      controller.connect();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 750,
        behavior: "smooth"
      });
    });

    it("should handle elements with offsetTop of 0", () => {
      const child = document.createElement("div");

      Reflect.defineProperty(child, "offsetTop", {
        value: 0,
        writable: false
      });

      mockContainer.appendChild(child);

      controller.disconnect();
      controller.connect();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 0,
        behavior: "smooth"
      });
    });
  });

  describe("when element with data-scroll-last-child does not exist", () => {
    it("should not scroll if no target element is found", () => {
      // Remove the element with data-scroll-last-child
      document.body.innerHTML = "";

      controller.disconnect();
      controller.connect();
      expect(global.window.scrollTo).not.toHaveBeenCalled();
    });
  });

  describe("with different child element types", () => {
    it("should work with various HTML elements as children", () => {
      const paragraph = document.createElement("p");
      const span = document.createElement("span");
      const div = document.createElement("div");

      Reflect.defineProperty(div, "offsetTop", {
        value: 180,
        writable: false
      });

      mockContainer.appendChild(paragraph);
      mockContainer.appendChild(span);
      mockContainer.appendChild(div);

      controller.disconnect();
      controller.connect();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 180,
        behavior: "smooth"
      });
    });
  });

  describe("edge cases", () => {
    it("should handle when container has only one child", () => {
      const singleChild = document.createElement("div");
      Reflect.defineProperty(singleChild, "offsetTop", {
        value: 50,
        writable: false
      });

      mockContainer.appendChild(singleChild);

      controller.disconnect();
      controller.connect();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 50,
        behavior: "smooth"
      });
    });

    it("should not throw error when children collection is empty", () => {
      expect(() => {
        controller.disconnect();
        controller.connect();
      }).not.toThrow();

      expect(global.window.scrollTo).not.toHaveBeenCalled();
    });

    it("should handle undefined node parameter by using document", () => {
      const child = document.createElement("div");
      Reflect.defineProperty(child, "offsetTop", {
        value: 150,
        writable: false
      });

      mockContainer.appendChild(child);

      controller.disconnect();
      controller.connect();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 150,
        behavior: "smooth"
      });
    });
  });
});
