/* global jest */
/* eslint max-lines: ["error", 360] */
import { Application } from "@hotwired/stimulus"
import SelectiveDisplayController from "src/decidim/controllers/selective_display/controller";

describe("SelectiveDisplayController", () => {
  let application = null;
  let controllers = null;
  let selectElement = null;
  let display1 = null;
  let display2 = null;
  let display12 = null;

  beforeEach(() => {
    application = Application.start();
    application.register("selective-display", SelectiveDisplayController);

    document.body.innerHTML = `
      <div>
        <label for="select_control">Selection</label>
        <select id="select_control">
          <option value="">None</option>
          <option value="opt1">Option 1</option>
          <option value="opt2">Option 2</option>
        </select>
      </div>

      <div data-controller="selective-display" data-selective-display-selector-value="#select_control" data-selective-display-triggers-value="opt1" class="hide">
        Display for option 1.
      </div>

      <div data-controller="selective-display" data-selective-display-selector-value="#select_control" data-selective-display-triggers-value="opt2" class="hide">
        Display for option 2.
      </div>

      <div data-controller="selective-display" data-selective-display-selector-value="#select_control" data-selective-display-triggers-value="opt1 opt2" class="hide">
        Display for option 1 and 2.
      </div>
    `;

    selectElement = document.querySelector("select#select_control");
    display1 = document.querySelector("div[data-selective-display-triggers-value='opt1']");
    display2 = document.querySelector("div[data-selective-display-triggers-value='opt2']");
    display12 = document.querySelector("div[data-selective-display-triggers-value='opt1 opt2']");

    return new Promise((resolve) => {
      setTimeout(() => {
        controllers = [
          application.getControllerForElementAndIdentifier(display1, "selective-display"),
          application.getControllerForElementAndIdentifier(display2, "selective-display"),
          application.getControllerForElementAndIdentifier(display12, "selective-display")
        ];
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  describe("connect / disconnect", () => {
    it("adds a change listener on connect", () => {
      const addSpy = jest.spyOn(selectElement, "addEventListener");

      controllers[0].disconnect();
      controllers[0].connect();

      expect(addSpy).toHaveBeenCalledWith("change", expect.any(Function));
      addSpy.mockRestore();
    });

    it("removes the change listener on disconnect", () => {
      const removeSpy = jest.spyOn(selectElement, "removeEventListener");
      const proxy = controllers[0]._changeListenerProxy;

      controllers[0].disconnect();

      expect(removeSpy).toHaveBeenCalledWith("change", proxy);
      removeSpy.mockRestore();
    });

    it("displays the selected option's content on connect", () => {
      selectElement.value = "opt1";

      for (const controller of controllers) {
        controller.disconnect();
        controller.connect();
      }

      expect(display1.classList.contains("hide")).toBe(false);
      expect(display2.classList.contains("hide")).toBe(true);
      expect(display12.classList.contains("hide")).toBe(false);
    });
  });

  describe("handleChange", () => {
    it("shows the correct content for option 1", () => {
      selectElement.value = "opt1";
      selectElement.dispatchEvent(new Event("change"));

      expect(display1.classList.contains("hide")).toBe(false);
      expect(display2.classList.contains("hide")).toBe(true);
      expect(display12.classList.contains("hide")).toBe(false);
    });

    it("shows the correct content for option 2", () => {
      selectElement.value = "opt2";
      selectElement.dispatchEvent(new Event("change"));

      expect(display1.classList.contains("hide")).toBe(true);
      expect(display2.classList.contains("hide")).toBe(false);
      expect(display12.classList.contains("hide")).toBe(false);
    });

    it("does not display anything for the empty option", () => {
      selectElement.value = "";
      selectElement.dispatchEvent(new Event("change"));

      expect(display1.classList.contains("hide")).toBe(true);
      expect(display2.classList.contains("hide")).toBe(true);
      expect(display12.classList.contains("hide")).toBe(true);
    });
  });
});
