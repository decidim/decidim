/* global jest */

import { createDialog } from "src/decidim/a11y"

describe("a11y dialog focus trap", () => {
  const dialogHtml = `
    <button id="open-btn" data-dialog-open="testDialog">Open</button>
    <div id="test-dialog" data-dialog="testDialog">
      <div data-dialog-container>
        <h2 id="dialog-title-testDialog" tabindex="-1" data-dialog-title>Test Dialog</h2>
        <a href="#">Link 1</a>
        <button>Button 1</button>
        <input type="text" />
        <button>Button 2</button>
        <a href="#">Link 2</a>
      </div>
      <div data-dialog-actions>
        <button data-dialog-close="testDialog">Close</button>
      </div>
    </div>
  `;

  beforeEach(() => {
    document.body.innerHTML = dialogHtml;
    window.Decidim = {
      currentDialogs: {}
    };
    window.focusGuard = {
      trap: jest.fn(),
      disable: jest.fn()
    };
  });

  describe("keydown handler", () => {
    let dialogEl = null;

    beforeEach(() => {
      const component = document.querySelector("[data-dialog]");
      createDialog(component);
      dialogEl = document.querySelector("[data-dialog='testDialog']");
      // Get the dialog from Decidim.currentDialogs and open it
      const dialog = window.Decidim.currentDialogs.testDialog;
      dialog.open();
    });

    it("adds keydown handler on open", () => {
      expect(dialogEl._focusTrapHandler).toBeDefined();
    });

    it("handles Tab key", () => {
      const selectors = "a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex='-1'])";
      const tabbableElements = Array.from(dialogEl.querySelectorAll(selectors)).filter(
        (el) => el.offsetParent || el.offsetParent === null
      );
      tabbableElements[tabbableElements.length - 1].focus();

      const event = new KeyboardEvent("keydown", { key: "Tab", bubbles: true });
      const preventDefault = jest.fn();
      event.preventDefault = preventDefault;

      dialogEl.dispatchEvent(event);

      expect(preventDefault).toHaveBeenCalled();
    });
  });

  describe("onClose cleanup", () => {
    it("removes the keydown handler on close", () => {
      const component = document.querySelector("[data-dialog]");
      createDialog(component);
      const dialogEl = document.querySelector("[data-dialog='testDialog']");

      const dialog = window.Decidim.currentDialogs.testDialog;
      dialog.open();
      expect(dialogEl._focusTrapHandler).toBeDefined();

      dialog.close();
      expect(dialogEl._focusTrapHandler).toBeUndefined();
    });
  });
});
