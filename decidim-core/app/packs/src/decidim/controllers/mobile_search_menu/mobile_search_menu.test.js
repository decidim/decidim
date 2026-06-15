/* global jest */
import { Application } from "@hotwired/stimulus"
import MobileSearchMenuController from "src/decidim/controllers/mobile_search_menu/controller";

describe("MobileSearchMenuController", () => {
  let application = null;
  let controller = null;
  let menuElement = null;
  let closeDiv = null;
  let dropdownTrigger = null;

  beforeEach(() => {
    application = Application.start();
    application.register("mobile-search-menu", MobileSearchMenuController);

    document.body.innerHTML = `
      <div id="dropdown-trigger-links-mobile-search"></div>
      <div id="dropdown-menu-search-mobile" class="main-bar__links-mobile__search" aria-hidden="true" data-controller="mobile-search-menu">
        <div class="main-bar">
          <div>
            <div class="main-bar__links-mobile__trigger" data-action="click->mobile-search-menu#close"></div>
          </div>
        </div>
      </div>
    `;

    menuElement = document.querySelector("#dropdown-menu-search-mobile");
    closeDiv = document.querySelector(".main-bar__links-mobile__trigger");
    dropdownTrigger = document.querySelector("#dropdown-trigger-links-mobile-search");

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(menuElement, "mobile-search-menu");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  describe("close", () => {
    it("proxies a click to the external dropdown trigger when the close element is clicked", () => {
      const clickSpy = jest.spyOn(dropdownTrigger, "click");

      closeDiv.dispatchEvent(new Event("click", { bubbles: true }));

      expect(clickSpy).toHaveBeenCalledTimes(1);
      clickSpy.mockRestore();
    });

    it("proxies a click when the method is invoked directly", () => {
      const clickSpy = jest.spyOn(dropdownTrigger, "click");

      controller.close();

      expect(clickSpy).toHaveBeenCalledTimes(1);
      clickSpy.mockRestore();
    });

    it("does nothing when the external dropdown trigger is missing", () => {
      dropdownTrigger.remove();

      expect(() => controller.close()).not.toThrow();
    });
  });
});
