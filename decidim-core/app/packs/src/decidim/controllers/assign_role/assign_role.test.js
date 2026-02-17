/* global global, jest */

import { Application } from "@hotwired/stimulus";
import AssignRoleController from "src/decidim/controllers/assign_role/controller";

describe("AssignRoleController", () => {
  let application = null;
  let element = null;
  let controller = null;

  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="assign-role" data-role="navigation"></div>
    `;

    application = Application.start();
    application.register("assign-role", AssignRoleController);

    element = document.querySelector('[data-controller="assign-role"]');

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "assign-role");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    jest.useRealTimers();
    jest.restoreAllMocks();
  });

  describe("connect", () => {
    it("sets the role attribute after the delay", () => {
      controller.disconnect();
      jest.useFakeTimers();

      controller.connect();

      expect(element.getAttribute("role")).toBeNull();
      jest.advanceTimersByTime(300);
      expect(element.getAttribute("role")).toBe("navigation");
    });

    it("returns early when no data-role is provided", () => {
      controller.disconnect();

      element.dataset.role = "";
      const setTimeoutSpy = jest.spyOn(global, "setTimeout");
      jest.useFakeTimers();

      controller.connect();

      expect(element.getAttribute("role")).toBeNull();
      expect(setTimeoutSpy).not.toHaveBeenCalled();
      jest.advanceTimersByTime(300);
      expect(element.getAttribute("role")).toBeNull();
    });
  });

  describe("disconnect", () => {
    it("clears any pending timeout", () => {
      controller.disconnect();
      jest.useFakeTimers();

      const clearTimeoutSpy = jest.spyOn(global, "clearTimeout");

      controller.connect();
      controller.disconnect();

      expect(clearTimeoutSpy).toHaveBeenCalled();

      jest.advanceTimersByTime(300);
      expect(element.getAttribute("role")).toBeNull();
    });
  });
});
