/* eslint-disable no-invalid-this */
/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["e"] }] */

document.addEventListener("DOMContentLoaded", () => {
  const selectedModerationsCount = () => {
    return document.querySelectorAll(".table-list .js-check-all-moderations:checked").length;
  };

  const selectedModerationsCountUpdate = () => {
    const selectedModerations = selectedModerationsCount();

    const countElement = document.getElementById("js-selected-moderations-count");
    const hideActions = document.getElementById("js-hide-global-moderations-actions");
    const unhideActions = document.getElementById("js-unhide-global-moderations-actions");
    const unreportActions = document.getElementById("js-unreport-global-moderations-actions");

    if (selectedModerations === 0) {
      countElement.textContent = "";
      hideActions.classList.add("hide");
      unhideActions.classList.add("hide");
      unreportActions.classList.add("hide");
    } else {
      countElement.textContent = selectedModerations;
    }
  };

  const showBulkActionsButton = () => {
    if (selectedModerationsCount() > 0) {
      document.getElementById("js-bulk-actions-button").classList.remove("hide");
    }
  };

  const hideBulkActionsButton = (force = false) => {
    const bulkActionsButton = document.getElementById("js-bulk-actions-button");
    const bulkActionsDropdown = document.getElementById("js-bulk-actions-dropdown");

    if (selectedModerationsCount() === 0 || force === true) {
      bulkActionsButton.classList.add("hide");
      bulkActionsDropdown.classList.remove("is-open");
    }
  }

  const showOtherActionsButtons = () => {
    document.getElementById("js-other-actions-wrapper").classList.remove("hide");
  };

  const hideOtherActionsButtons = () => {
    document.getElementById("js-other-actions-wrapper").classList.add("hide");
  };

  const hideBulkActionForms = () => {
    document.querySelectorAll(".js-bulk-action-form").forEach((form) => {
      form.classList.add("hide");
    });
  }

  // Expose functions to make them available in .js.erb templates
  window.selectedModerationsCountUpdate = selectedModerationsCountUpdate;
  window.showBulkActionsButton = showBulkActionsButton;
  window.hideBulkActionsButton = hideBulkActionsButton;
  window.showOtherActionsButtons = showOtherActionsButtons;
  window.hideOtherActionsButtons = hideOtherActionsButtons;
  window.hideBulkActionForms = hideBulkActionForms;

  const bulkActionsButton = document.getElementById("js-bulk-actions-button");

  if (document.querySelectorAll(".js-bulk-action-form").length) {
    hideBulkActionForms();
    bulkActionsButton.classList.add("hide");

    document.querySelectorAll("#js-bulk-actions-dropdown li button").forEach((button) => {
      button.addEventListener("click", (event) => {
        const bulkActionsDropdown = document.getElementById("js-bulk-actions-dropdown");
        bulkActionsDropdown.classList.remove("is-open");
        hideBulkActionForms();

        const action = event.target.dataset.action;
        const panelActions = [
          "hide-global-moderations",
          "unreport-global-moderations",
          "unhide-global-moderations"
        ];

        if (!action) {
          return;
        }

        const form = document.getElementById(`js-form-${action}`);
        const actionElement = document.getElementById(`js-${action}-actions`);

        if (panelActions.includes(action)) {
          form.addEventListener("submit", () => {
            document.querySelector(".layout-content > div[data-callout-wrapper]").innerHTML = "";
          });

          actionElement.classList.remove("hide");
        } else {
          form.addEventListener("submit", () => {
            document.querySelector(".layout-content > div[data-callout-wrapper]").innerHTML = "";
          });

          actionElement.classList.remove("hide");
          hideBulkActionsButton(true);
          hideOtherActionsButtons();
        }
      });
    });

    // select all checkboxes
    const moderatedContentList = document.getElementById("moderations_bulk");
    if (moderatedContentList !== null) {
      moderatedContentList.addEventListener("change", function () {
        const isChecked = this.checked;
        const checkboxes = document.querySelectorAll(".js-check-all-moderations");

        checkboxes.forEach((checkbox) => {
          checkbox.checked = isChecked;
          const row = checkbox.closest("tr");
          if (row) {
            row.classList.toggle("selected", isChecked);
          }
        });

        if (isChecked) {
          showBulkActionsButton();
        } else {
          hideBulkActionsButton();
        }

        selectedModerationsCountUpdate();
      });
    }

    // moderation checkbox change
    document.querySelector(".table-list").addEventListener("change", (event) => {
      if (!event.target.matches(".js-check-all-moderations")) {
        return;
      }

      const checkbox = event.target;
      const moderationId = checkbox.value;
      const checked = checkbox.checked;

      // Uncheck "select all" if one of the checkboxes is unchecked
      const selectAllCheckbox = document.querySelector(".js-check-all");
      if (!checked) {
        selectAllCheckbox.checked = false;
      }

      // check "select all" if all checkbox moderations are checked
      const allCheckboxes = Array.from(document.querySelectorAll(".js-check-all-moderations")).filter((checkboxItem) => checkboxItem.offsetParent !== null);
      const checkedCheckboxes = Array.from(document.querySelectorAll(".js-check-all-moderations:checked")).filter((checkboxItem) => checkboxItem.offsetParent !== null);

      if (allCheckboxes.length === checkedCheckboxes.length) {
        selectAllCheckbox.checked = true;
        showBulkActionsButton();
      }

      const row = checkbox.closest("tr");
      if (row) {
        row.classList.toggle("selected", checked);
      }

      if (checked) {
        showBulkActionsButton();
      } else {
        hideBulkActionsButton();
      }

      if (checkedCheckboxes.length === 0) {
        hideBulkActionsButton();
      }

      document.querySelectorAll(`.js-moderation-id-${moderationId}`).forEach((input) => {
        input.checked = checked;
      });
      selectedModerationsCountUpdate();
    });

    document.querySelectorAll(".js-cancel-bulk-action").forEach((button) => {
      button.addEventListener("click", () => {
        hideBulkActionForms();
        showBulkActionsButton();
        showOtherActionsButtons();
      });
    });
  }
});
