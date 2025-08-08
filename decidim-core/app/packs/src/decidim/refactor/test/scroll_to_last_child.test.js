/* global global, jest */

import scrollToLastChild from "src/decidim/refactor/implementation/scroll_to_last_child";

describe("scrollToLastChild", () => {
  let mockContainer = null;

  beforeEach(() => {
    // Reset DOM
    document.body.innerHTML = "";

    // Mock window.scrollTo
    global.window.scrollTo = jest.fn();

    // Create mock container element
    mockContainer = document.createElement("div");
    mockContainer.setAttribute("data-scroll-last-child", "");
    document.body.appendChild(mockContainer);
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

      scrollToLastChild();

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 500,
        behavior: "smooth"
      });
    });
  });

  describe("when called with a specific node", () => {
    it("should search within the provided node", () => {
      const customNode = document.createElement("section");
      const containerInCustomNode = document.createElement("div");
      containerInCustomNode.setAttribute("data-scroll-last-child", "");

      const child1 = document.createElement("div");
      const child2 = document.createElement("div");
      // Mock offsetTop property for the last child
      Reflect.defineProperty(child2, "offsetTop", {
        value: 300,
        writable: false
      });

      containerInCustomNode.appendChild(child1);
      containerInCustomNode.appendChild(child2);
      customNode.appendChild(containerInCustomNode);

      scrollToLastChild(customNode);

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 300,
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

      scrollToLastChild(document);

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 250,
        behavior: "smooth"
      });
    });

    it("should not scroll when no children exist", () => {
      scrollToLastChild(document);

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

      scrollToLastChild(document);

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

      scrollToLastChild(document);

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

      scrollToLastChild(document);

      expect(global.window.scrollTo).not.toHaveBeenCalled();
    });
  });

  describe("when multiple elements with data-scroll-last-child exist", () => {
    it("should only process the first matching element", () => {
      const container1 = document.createElement("div");
      container1.setAttribute("data-scroll-last-child", "");

      const container2 = document.createElement("div");
      container2.setAttribute("data-scroll-last-child", "");

      const child1 = document.createElement("div");
      Reflect.defineProperty(child1, "offsetTop", {
        value: 100,
        writable: false
      });

      const child2 = document.createElement("div");
      Reflect.defineProperty(child2, "offsetTop", {
        value: 200,
        writable: false
      });

      container1.appendChild(child1);
      container2.appendChild(child2);

      document.body.innerHTML = "";
      document.body.appendChild(container1);
      document.body.appendChild(container2);

      scrollToLastChild(document);

      // Should scroll to the last child of the first matching container
      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 100,
        behavior: "smooth"
      });
      expect(global.window.scrollTo).toHaveBeenCalledTimes(1);
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

      scrollToLastChild(document);

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

      scrollToLastChild(document);

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 50,
        behavior: "smooth"
      });
    });

    it("should not throw error when children collection is empty", () => {
      expect(() => {
        scrollToLastChild(document);
      }).not.toThrow();

      expect(global.window.scrollTo).not.toHaveBeenCalled();
    });

    it("should handle null node parameter gracefully", () => {
      expect(() => {
        scrollToLastChild(null);
      }).toThrow();
    });

    it("should handle undefined node parameter by using document", () => {
      const child = document.createElement("div");
      Reflect.defineProperty(child, "offsetTop", {
        value: 150,
        writable: false
      });

      mockContainer.appendChild(child);

      // eslint-disable-next-line no-undefined
      scrollToLastChild(undefined);

      expect(global.window.scrollTo).toHaveBeenCalledWith({
        top: 150,
        behavior: "smooth"
      });
    });
  });
});
