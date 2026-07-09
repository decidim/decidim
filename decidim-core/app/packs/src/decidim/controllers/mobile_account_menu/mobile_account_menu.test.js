import { Application } from "@hotwired/stimulus"
import MobileAccountMenuController from "src/decidim/controllers/mobile_account_menu/controller"

describe("MobileAccountMenuController", () => {
  let application = null;
  let controller = null;
  let element = null;
  let closeDiv = null;
  let dropdownTrigger = null;

  beforeEach(() => {
    document.body.innerHTML = `
      <button id="dropdown-trigger-links-mobile"></button>
      <div id="dropdown-menu-account-mobile" aria-hidden="true" aria-modal="true" data-controller="mobile-account-menu">
        <div id="dropdown-trigger-links-mobile-close" class="main-bar__links-mobile__trigger" tabindex="0" data-action="keydown->mobile-account-menu#close"></div>
      </div>
    `;

    element = document.querySelector("#dropdown-menu-account-mobile");
    closeDiv = document.querySelector("#dropdown-trigger-links-mobile-close");
    dropdownTrigger = document.querySelector("#dropdown-trigger-links-mobile");

    application = Application.start();
    application.register("mobile-account-menu", MobileAccountMenuController);

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "mobile-account-menu");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
  });

  describe("close", () => {
    it("hides the menu and focuses the trigger on Enter", () => {
      closeDiv.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 13, bubbles: true }));

      expect(element.hasAttribute("aria-modal")).toBe(false);
      expect(element.getAttribute("aria-hidden")).toBe("true");
      expect(document.activeElement).toBe(dropdownTrigger);
    });

    it("hides the menu and focuses the trigger on Space", () => {
      closeDiv.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 32, bubbles: true }));

      expect(element.hasAttribute("aria-modal")).toBe(false);
      expect(element.getAttribute("aria-hidden")).toBe("true");
      expect(document.activeElement).toBe(dropdownTrigger);
    });

    it("ignores keys other than Enter and Space", () => {
      closeDiv.dispatchEvent(new KeyboardEvent("keydown", { keyCode: 27, bubbles: true }));

      expect(element.hasAttribute("aria-modal")).toBe(true);
      expect(document.activeElement).not.toBe(dropdownTrigger);
    });

    it("controller is registered", () => {
      expect(controller).not.toBeNull();
    });
  });
});
