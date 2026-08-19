/* global jest */

import { Application } from "@hotwired/stimulus";
import ManagedModeratedUsersController from "src/decidim/admin/controllers/managed_moderated_users/controller";

const PANEL_ACTIONS = ["block-moderated_users", "unreport-moderated_users", "unblock-moderated_users"];

const buildHTML = () => `
  <div data-controller="managed-moderated-users">
    <div id="js-other-actions-wrapper"></div>
    <button id="js-bulk-actions-button" class="hide"></button>
    <ul id="js-bulk-actions-dropdown">
      ${PANEL_ACTIONS.map((action) => `<li><button data-action="${action}">Action</button></li>`).join("")}
    </ul>
    ${PANEL_ACTIONS.map((action) => `
      <form id="js-form-${action}" class="js-bulk-action-form hide"></form>
      <div id="js-${action}-actions" class="hide"></div>
    `).join("")}
    <span id="js-selected-moderated_users-count"></span>
    <input type="checkbox" id="moderated_users_bulk" class="js-check-all" />
    <table class="table-list">
      <tbody>
        <tr>
          <td><input type="checkbox" class="js-check-all-moderated_users" value="1" /></td>
          <td><input type="hidden" class="js-moderated_user-id-1" /></td>
        </tr>
        <tr>
          <td><input type="checkbox" class="js-check-all-moderated_users" value="2" /></td>
          <td><input type="hidden" class="js-moderated_user-id-2" /></td>
        </tr>
      </tbody>
    </table>
    <button class="js-cancel-bulk-action">Cancel</button>
  </div>
`;

describe("ManagedModeratedUsersController", () => {
  let application = null;
  let controller = null;
  let element = null;

  beforeEach(() => {
    document.body.innerHTML = buildHTML();
    element = document.querySelector("[data-controller='managed-moderated-users']");
    application = Application.start();
    application.register("managed-moderated-users", ManagedModeratedUsersController);

    return new Promise((resolve) => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, "managed-moderated-users");
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

    it("attaches change listener to #moderated_users_bulk", () => {
      controller.disconnect();
      const selectAll = element.querySelector("#moderated_users_bulk");
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
  });


  describe("disconnect()", () => {
    it("removes change listener from #moderated_users_bulk", () => {
      const selectAll = element.querySelector("#moderated_users_bulk");
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

  describe("selectedModeratedUsersCount()", () => {
    it("returns 0 when no checkboxes are checked", () => {
      expect(controller.selectedModeratedUsersCount()).toBe(0);
    });

    it("returns correct count when one checkbox is checked", () => {
      const checkboxes = element.querySelectorAll(".js-check-all-moderated_users");
      checkboxes[0].checked = true;
      expect(controller.selectedModeratedUsersCount()).toBe(1);
    });
  });


  describe("selectedModeratedUsersCountUpdate()", () => {
    it("sets count element text to empty string when count is 0", () => {
      const countEl = element.querySelector("#js-selected-moderated_users-count");
      countEl.textContent = "5";
      controller.selectedModeratedUsersCountUpdate();
      expect(countEl.textContent).toBe("");
    });

    it("hides action panels when count is 0", () => {
      PANEL_ACTIONS.forEach((action) => {
        const actionEl = element.querySelector(`#js-${action}-actions`);
        if (actionEl) {
          actionEl.classList.remove("hide");
        }
      });
      controller.selectedModeratedUsersCountUpdate();
      PANEL_ACTIONS.forEach((action) => {
        const actionEl = element.querySelector(`#js-${action}-actions`);
        if (actionEl) {
          expect(actionEl.classList.contains("hide")).toBe(true);
        }
      });
    });

    it("sets count element text to selected count when count > 0", () => {
      element.querySelectorAll(".js-check-all-moderated_users").forEach((cb) => {
        cb.checked = true;
      });
      const countEl = element.querySelector("#js-selected-moderated_users-count");
      controller.selectedModeratedUsersCountUpdate();
      expect(countEl.textContent).toBe("2");
    });

    it("does not hide action panels when count > 0", () => {
      element.querySelectorAll(".js-check-all-moderated_users").forEach((cb) => {
        cb.checked = true;
      });
      const actionEl = element.querySelector(`#js-${PANEL_ACTIONS[0]}-actions`);
      if (actionEl) {
        actionEl.classList.remove("hide");
      }
      controller.selectedModeratedUsersCountUpdate();
      if (actionEl) {
        expect(actionEl.classList.contains("hide")).toBe(false);
      }
    });
  });


  describe("showBulkActionsButton()", () => {
    it("shows button when count > 0", () => {
      element.querySelectorAll(".js-check-all-moderated_users").forEach((cb) => {
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
      element.querySelectorAll(".js-check-all-moderated_users").forEach((cb) => {
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

  describe("showOtherActionsButtons()", () => {
    it("removes 'hide' class from #js-other-actions-wrapper", () => {
      const wrapper = element.querySelector("#js-other-actions-wrapper");
      wrapper.classList.add("hide");
      controller.showOtherActionsButtons();
      expect(wrapper.classList.contains("hide")).toBe(false);
    });
  });

  describe("hideOtherActionsButtons()", () => {
    it("adds 'hide' class to #js-other-actions-wrapper", () => {
      const wrapper = element.querySelector("#js-other-actions-wrapper");
      wrapper.classList.remove("hide");
      controller.hideOtherActionsButtons();
      expect(wrapper.classList.contains("hide")).toBe(true);
    });
  });

  describe("hideBulkActionForms()", () => {
    it("adds 'hide' class to all .js-bulk-action-form elements", () => {
      element.querySelectorAll(".js-bulk-action-form").forEach((form) => {
        form.classList.remove("hide");
      });
      controller.hideBulkActionForms();
      element.querySelectorAll(".js-bulk-action-form").forEach((form) => {
        expect(form.classList.contains("hide")).toBe(true);
      });
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
      element.querySelectorAll(".js-check-all-moderated_users").forEach((cb) => {
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
