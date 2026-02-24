/* global jest */
/* eslint max-lines: ["error", 360] */
import { Application } from "@hotwired/stimulus"
import LanguageChangeController from "src/decidim/controllers/language_change/controller";

describe("LanguageChangeController", () => {
  let application = null;
  let controller = null;
  let selectElement = null;
  let tabsContent = null;
  let panel0 = null;
  let panel1 = null;

  beforeEach(() => {
    application = Application.start();
    application.register("language-change", LanguageChangeController);

    document.body.innerHTML = `
      <div class="label--tabs">
        <label for="update_organization_name">Name</label>
        <div>
          <select id="update_organization-name-tabs" class="language-change" data-controller="language-change">
            <option value="#update_organization-name-tabs-name-panel-0">English</option>
            <option value="#update_organization-name-tabs-name-panel-1">Bulgarian</option>
          </select>
        </div>
      </div>
      <div class="tabs-content" data-tabs-content="update_organization-name-tabs">
        <div class="tabs-panel is-active" id="update_organization-name-tabs-name-panel-0" aria-hidden="false">
          <input type="text" value="Example" name="update_organization[name_en]" id="update_organization_name_en">
        </div>
        <div class="tabs-panel" id="update_organization-name-tabs-name-panel-1" aria-hidden="true">
          <input type="text" value="Example BG" name="update_organization[name_bg]" id="update_organization_name_bg">
        </div>
      </div>
    `;

    selectElement = document.querySelector("select[data-controller='language-change']");
    tabsContent = document.querySelector(".tabs-content");
    panel0 = document.querySelector("#update_organization-name-tabs-name-panel-0");
    panel1 = document.querySelector("#update_organization-name-tabs-name-panel-1");

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(selectElement, "language-change");
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

      controller.disconnect();
      controller.connect();

      expect(addSpy).toHaveBeenCalledWith("change", expect.any(Function));
      addSpy.mockRestore();
    });

    it("removes the change listener on disconnect", () => {
      const removeSpy = jest.spyOn(selectElement, "removeEventListener");

      controller.disconnect();

      expect(removeSpy).toHaveBeenCalledWith("change", controller.handleChange);
      removeSpy.mockRestore();
    });
  });

  describe("handleChange", () => {
    it("toggles active tab panel and aria-hidden", () => {
      selectElement.value = "#update_organization-name-tabs-name-panel-1";

      controller.handleChange({ target: selectElement });

      expect(panel0.classList.contains("is-active")).toBe(false);
      expect(panel0.ariaHidden).toBe("true");
      expect(panel1.classList.contains("is-active")).toBe(true);
      expect(panel1.ariaHidden).toBe("false");
    });

    it("does nothing when tabs content is missing", () => {
      tabsContent.remove();

      expect(() => controller.handleChange({ target: selectElement })).not.toThrow();
    });

    it("activates the target panel when no panel is active", () => {
      panel0.classList.remove("is-active");

      selectElement.value = "#update_organization-name-tabs-name-panel-1";
      controller.handleChange({ target: selectElement });

      expect(panel1.classList.contains("is-active")).toBe(true);
      expect(panel1.ariaHidden).toBe("false");
    });
  });
});
