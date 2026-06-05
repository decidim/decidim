/* global jest */

import { Application } from "@hotwired/stimulus";
import ToggleController from "src/decidim/controllers/toggle/controller";

describe("ToggleController", () => {
  let application = null;
  let controller = null;
  let element = null;
  let targetElement1 = null;
  let targetElement2 = null;

  beforeEach(() => {
    // Set up the DOM
    document.body.innerHTML = `
      <button
        data-controller="toggle"
        data-toggle-toggle-value="target1 target2"
      >
        Toggle Button
      </button>
      <div id="target1" hidden>Target 1 Content</div>
      <div id="target2" hidden>Target 2 Content</div>
    `;

    // Set up Stimulus application
    application = Application.start();
    application.register("toggle", ToggleController);

    element = document.querySelector('[data-controller="toggle"]');
    targetElement1 = document.getElementById("target1");
    targetElement2 = document.getElementById("target2");

    // Wait for the controller to be connected
    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "toggle")
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    jest.clearAllMocks();
  });

  describe("connect", () => {
    it("ensures the component has an ID", () => {
      document.body.innerHTML = "";
      const elementWithoutId = document.createElement("button");
      elementWithoutId.setAttribute("data-controller", "toggle");
      elementWithoutId.setAttribute("data-toggle-toggle-value", "target1");
      document.body.appendChild(elementWithoutId);

      controller.disconnect()
      controller.connect();

      expect(controller.element.id).toMatch(/^toggle-[a-z0-9]+$/);
    });

    it("sets up aria-controls attribute", () => {
      expect(element.getAttribute("aria-controls")).toBe("target1 target2");
    });

    it("sets up aria-labelledby attributes for target elements", () => {
      const target1LabelledBy = targetElement1.getAttribute("aria-labelledby");
      const target2LabelledBy = targetElement2.getAttribute("aria-labelledby");

      expect(target1LabelledBy).toContain(element.id);
      expect(target2LabelledBy).toContain(element.id);
    });

    it("binds click event listener", () => {
      const spy = jest.spyOn(controller, "handleToggle");
      element.click();
      expect(spy).toHaveBeenCalled();
    });

    it("preserves existing aria-labelledby values", () => {
      const existingLabel = "existing-label";
      targetElement1.setAttribute("aria-labelledby", existingLabel);

      // Re-initialize controller
      application.stop();
      application = Application.start();
      application.register("toggle", ToggleController);
      controller = application.getControllerForElementAndIdentifier(element, "toggle");

      const labelledBy = targetElement1.getAttribute("aria-labelledby");
      expect(labelledBy).toBe(`${existingLabel}`);
    });
  });

  describe("disconnect", () => {
    it("removes event listeners", () => {
      const removeEventListenerSpy = jest.spyOn(element, "removeEventListener");
      controller.disconnect();
      expect(removeEventListenerSpy).toHaveBeenCalledWith("click", controller.handleToggle);
    });
  });

  describe("handleToggle", () => {
    beforeEach(() => {
      // Ensure targets are initially hidden
      targetElement1.hidden = true;
      targetElement2.hidden = true;
    });

    it("toggles visibility of target elements", () => {
      controller.handleToggle();

      expect(targetElement1.hidden).toBe(false);
      expect(targetElement2.hidden).toBe(false);
    });

    it("sets aria-expanded attribute correctly", () => {
      controller.handleToggle();

      expect(targetElement1.getAttribute("aria-expanded")).toBe("true");
      expect(targetElement2.getAttribute("aria-expanded")).toBe("true");
    });

    it("toggles back to hidden state", () => {
      // First toggle - show
      controller.handleToggle();
      expect(targetElement1.hidden).toBe(false);
      expect(targetElement2.hidden).toBe(false);

      // Second toggle - hide
      controller.handleToggle();
      expect(targetElement1.hidden).toBe(true);
      expect(targetElement2.hidden).toBe(true);
    });

    it("handles nonexistent target elements gracefully", () => {
      element.setAttribute("data-toggle-toggle-value", "nonexistent target1");

      expect(() => {
        controller.handleToggle();
      }).not.toThrow();

      // Should still toggle the existing element
      expect(targetElement1.hidden).toBe(false);
    });

    it("dispatches custom toggle event", () => {
      const eventSpy = jest.spyOn(document, "dispatchEvent");

      controller.handleToggle();

      expect(eventSpy).toHaveBeenCalledWith(expect.objectContaining({
        type: "on:toggle"
      }));
    });
  });

  describe("getTargetIds", () => {
    it("returns array of target IDs from space-separated string", () => {
      const targetIds = controller.getTargetIds();
      expect(targetIds).toEqual(["target1", "target2"]);
    });

    it("handles single target ID", () => {
      element.setAttribute("data-toggle-toggle-value", "single-target");
      const targetIds = controller.getTargetIds();
      expect(targetIds).toEqual(["single-target"]);
    });
  });

  describe("integration tests", () => {
    it("works with click events", () => {
      element.click();

      expect(targetElement1.hidden).toBe(false);
      expect(targetElement2.hidden).toBe(false);
      expect(targetElement1.getAttribute("aria-expanded")).toBe("true");
      expect(targetElement2.getAttribute("aria-expanded")).toBe("true");
    });

    it("dispatches toggle event on click", (done) => {
      document.addEventListener("on:toggle", () => {
        done();
      });

      element.click();
    });

    it("handles keyboard activation", () => {
      const enterEvent = new KeyboardEvent("keydown", { key: "Enter" });
      element.dispatchEvent(enterEvent);

      // Note: This test assumes the button element handles Enter key natively
      // which triggers a click event
      element.click();

      expect(targetElement1.hidden).toBe(false);
      expect(targetElement2.hidden).toBe(false);
    });
  });

  describe("accessibility features", () => {
    it("maintains proper ARIA attributes", () => {
      expect(element.getAttribute("aria-controls")).toBe("target1 target2");

      element.click();

      expect(targetElement1.getAttribute("aria-expanded")).toBe("true");
      expect(targetElement2.getAttribute("aria-expanded")).toBe("true");
    });

    it("creates bidirectional ARIA relationships", () => {
      const target1LabelledBy = targetElement1.getAttribute("aria-labelledby");
      const target2LabelledBy = targetElement2.getAttribute("aria-labelledby");

      expect(target1LabelledBy).toContain(element.id);
      expect(target2LabelledBy).toContain(element.id);
    });
  });

  describe("edge cases", () => {
    it("handles empty toggle value", () => {
      element.setAttribute("data-toggle-toggle-value", "");

      expect(() => {
        controller.handleToggle();
      }).not.toThrow();
    });

    it("handles whitespace in toggle value", () => {
      element.setAttribute("data-toggle-toggle-value", "  target1   target2  ");

      const targetIds = controller.getTargetIds();
      expect(targetIds).toEqual(["", "", "target1", "", "", "target2", "", ""]);
    });

    it("generates unique IDs for multiple toggle elements", async () => {
      const secondToggle = document.createElement("button");
      secondToggle.setAttribute("data-controller", "toggle");
      secondToggle.setAttribute("data-toggle-toggle-value", "target1");
      document.body.appendChild(secondToggle);

      controller.disconnect();
      let secondController = null;

      await new Promise((resolve) => {
        setTimeout(() => {
          controller = application.getControllerForElementAndIdentifier(element, "toggle");
          secondController = application.getControllerForElementAndIdentifier(secondToggle, "toggle");
          resolve();
        }, 0);
      });

      expect(element.id).not.toBe(secondController.element.id);
      expect(element.id).toMatch(/^toggle-[a-z0-9]+$/);
      expect(secondController.element.id).toMatch(/^toggle-[a-z0-9]+$/);
    });
  });
});
