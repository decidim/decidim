/* global jest */

import { Application } from "@hotwired/stimulus";
import GlobalModerationsController from "src/decidim/admin/controllers/global_moderations/controller";

const PANEL_ACTIONS = ["hide-global-moderations", "unreport-global-moderations", "unhide-global-moderations"];

const buildHTML = () => `
  <div data-controller="global-moderations">
    <div id="js-other-actions-wrapper"></div>
    <button id="js-bulk-actions-button" class="hide"></button>
    <ul id="js-bulk-actions-dropdown">
      ${PANEL_ACTIONS.map((action) => `<li><button data-action="${action}">Action</button></li>`).join("")}
    </ul>
    ${PANEL_ACTIONS.map((action) => `
      <form id="js-form-${action}" class="js-bulk-action-form hide"></form>
      <div id="js-${action}-actions" class="hide"></div>
    `).join("")}
    <span id="js-selected-moderations-count"></span>
    <input type="checkbox" id="moderations_bulk" class="js-check-all" />
    <table class="table-list">
      <tbody>
        <tr>
          <td><input type="checkbox" class="js-check-all-moderations" value="1" /></td>
          <td><input type="hidden" class="js-moderation-id-1" /></td>
        </tr>
        <tr>
          <td><input type="checkbox" class="js-check-all-moderations" value="2" /></td>
          <td><input type="hidden" class="js-moderation-id-2" /></td>
        </tr>
      </tbody>
    </table>
    <button class="js-cancel-bulk-action">Cancel</button>
  </div>
`;

describe("GlobalModerationsController", () => {
  let application = null;
  let controller = null;
  let element =  null;

  beforeEach(() => {
    document.body.innerHTML = buildHTML();
    element = document.querySelector("[data-controller='global-moderations']");
    application = Application.start();
    application.register("global-moderations", GlobalModerationsController);

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "global-moderations");
        resolve();
      }, 0);
    });
  });

  afterEach(() => {
    controller.disconnect();
    application.stop();
    document.body.innerHTML = "";
  });

  describe("connect()", () => {
    it("hides #js-bulk-actions-button on connect", () => {
      const btn = document.querySelector("#js-bulk-actions-button");
      expect(btn.classList.contains("hide")).toBe(true);
    });

    it("attaches click listeners to #js-bulk-actions-dropdown li button elements", () => {
      controller.disconnect();
      const buttons = element.querySelectorAll("#js-bulk-actions-dropdown li button");
      const spies = Array.from(buttons).map((btn) => jest.spyOn(btn, "addEventListener"));

      controller.connect();

      spies.forEach((spy) => {
        expect(spy).toHaveBeenCalledWith("click", controller._boundOnDropdownButtonClick);
      });
    });

    it("attaches change listener to #moderations_bulk", () => {
      controller.disconnect();
      const selectAll = element.querySelector("#moderations_bulk");
      const spy = jest.spyOn(selectAll, "addEventListener");

      controller.connect();

      expect(spy).toHaveBeenCalledWith("change", controller._boundOnSelectAllChange);
    });

    it("attaches change listener to .table-list", () => {
      controller.disconnect();
      const tableList = element.querySelector(".table-list");
      const spy = jest.spyOn(tableList, "addEventListener");

      controller.connect();

      expect(spy).toHaveBeenCalledWith("change", controller._boundOnTableListChange);
    });

    it("attaches click listeners to .js-cancel-bulk-action buttons", () => {
      controller.disconnect();
      const cancelBtns = element.querySelectorAll(".js-cancel-bulk-action");
      const spies = Array.from(cancelBtns).map((btn) => jest.spyOn(btn, "addEventListener"));

      controller.connect();

      spies.forEach((spy) => {
        expect(spy).toHaveBeenCalledWith("click", controller._boundOnCancelBulkAction);
      });
    });
  });

  describe("disconnect()", () => {
    it("removes click listeners from #js-bulk-actions-dropdown li button elements", () => {
      const buttons = element.querySelectorAll("#js-bulk-actions-dropdown li button");
      const spies = Array.from(buttons).map((btn) => jest.spyOn(btn, "removeEventListener"));

      const boundRef = controller._boundOnDropdownButtonClick;
      controller.disconnect();

      spies.forEach((spy) => {
        expect(spy).toHaveBeenCalledWith("click", boundRef);
      });
    });

    it("removes change listener from #moderations_bulk", () => {
      const selectAll = element.querySelector("#moderations_bulk");
      const spy = jest.spyOn(selectAll, "removeEventListener");
      const boundRef = controller._boundOnSelectAllChange;

      controller.disconnect();

      expect(spy).toHaveBeenCalledWith("change", boundRef);
    });

    it("removes change listener from .table-list", () => {
      const tableList = element.querySelector(".table-list");
      const spy = jest.spyOn(tableList, "removeEventListener");
      const boundRef = controller._boundOnTableListChange;

      controller.disconnect();

      expect(spy).toHaveBeenCalledWith("change", boundRef);
    });

    it("removes click listeners from .js-cancel-bulk-action buttons", () => {
      const cancelBtns = element.querySelectorAll(".js-cancel-bulk-action");
      const spies = Array.from(cancelBtns).map((btn) => jest.spyOn(btn, "removeEventListener"));
      const boundRef = controller._boundOnCancelBulkAction;

      controller.disconnect();

      spies.forEach((spy) => {
        expect(spy).toHaveBeenCalledWith("click", boundRef);
      });
    });
  });

  describe("selectedModerationsCount()", () => {
    it("returns 0 when no checkboxes are checked", () => {
      expect(controller.selectedModerationsCount()).toBe(0);
    });

    it("returns correct count when one checkbox is checked", () => {
      const checkboxes = element.querySelectorAll(".js-check-all-moderations");
      checkboxes[0].checked = true;
      expect(controller.selectedModerationsCount()).toBe(1);
    });

    it("returns correct count when all checkboxes are checked", () => {
      element.querySelectorAll(".js-check-all-moderations").forEach((cb) => {
        cb.checked = true;
      });
      expect(controller.selectedModerationsCount()).toBe(2);
    });
  });

  describe("selectedModerationsCountUpdate()", () => {
    it("sets count element text to empty string when count is 0", () => {
      const countEl = element.querySelector("#js-selected-moderations-count");
      countEl.textContent = "5";
      controller.selectedModerationsCountUpdate();
      expect(countEl.textContent).toBe("");
    });

    it("sets count element text to selected count when count > 0", () => {
      element.querySelectorAll(".js-check-all-moderations").forEach((cb) => {
        cb.checked = true;
      });
      const countEl = element.querySelector("#js-selected-moderations-count");
      controller.selectedModerationsCountUpdate();
      expect(countEl.textContent).toBe("2");
    });
  });

  describe("showBulkActionsButton()", () => {
    it("shows button when count > 0", () => {
      element.querySelectorAll(".js-check-all-moderations").forEach((cb) => {
        cb.checked = true;
      });
      const btn = element.querySelector("#js-bulk-actions-button");
      btn.classList.add("hide");
      controller.showBulkActionsButton();
      expect(btn.classList.contains("hide")).toBe(false);
    });

    it("does not show button when count is 0", () => {
      const btn = element.querySelector("#js-bulk-actions-button");
      btn.classList.add("hide");
      controller.showBulkActionsButton();
      expect(btn.classList.contains("hide")).toBe(true);
    });
  });

  describe("hideBulkActionsButton()", () => {
    it("hides button when count is 0", () => {
      const btn = element.querySelector("#js-bulk-actions-button");
      btn.classList.remove("hide");
      controller.hideBulkActionsButton();
      expect(btn.classList.contains("hide")).toBe(true);
    });

    it("does not hide button when count > 0", () => {
      element.querySelectorAll(".js-check-all-moderations").forEach((cb) => {
        cb.checked = true;
      });
      const btn = element.querySelector("#js-bulk-actions-button");
      btn.classList.remove("hide");
      controller.hideBulkActionsButton();
      expect(btn.classList.contains("hide")).toBe(false);
    });

    it("closes dropdown on hide", () => {
      const dropdown = element.querySelector("#js-bulk-actions-dropdown");
      dropdown.classList.add("is-open");
      controller.hideBulkActionsButton();
      expect(dropdown.classList.contains("is-open")).toBe(false);
    });
  });

  describe("_onDropdownButtonClick", () => {
    it("closes dropdown on button click", () => {
      const dropdown = element.querySelector("#js-bulk-actions-dropdown");
      dropdown.classList.add("is-open");
      const btn = element.querySelector("#js-bulk-actions-dropdown li button");
      btn.click();
      expect(dropdown.classList.contains("is-open")).toBe(false);
    });

    it("hides bulk actions button after click", () => {
      element.querySelectorAll(".js-check-all-moderations").forEach((cb) => {
        cb.checked = true;
      });
      const bulkBtn = element.querySelector("#js-bulk-actions-button");
      bulkBtn.classList.remove("hide");
      const btn = element.querySelector(`[data-action="${PANEL_ACTIONS[0]}"]`);
      btn.click();
      expect(bulkBtn.classList.contains("hide")).toBe(true);
    });
  });

  describe("_onCancelBulkAction", () => {
    it("hides bulk action forms on cancel", () => {
      element.querySelectorAll(".js-bulk-action-form").forEach((form) => {
        form.classList.remove("hide");
      });
      const cancelBtn = element.querySelector(".js-cancel-bulk-action");
      cancelBtn.click();
      element.querySelectorAll(".js-bulk-action-form").forEach((form) => {
        expect(form.classList.contains("hide")).toBe(true);
      });
    });
  });
});
