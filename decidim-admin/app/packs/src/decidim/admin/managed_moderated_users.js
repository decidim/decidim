/* eslint-disable no-invalid-this */
/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["e"] }] */

document.addEventListener("DOMContentLoaded", () => {
  const selectedModeratedUsersCount = () => {
    return document.querySelectorAll(".table-list .js-check-all-moderated_users:checked").length;
  };

  const selectedModeratedUsersCountUpdate = () => {
    const selectedModeratedUsers = selectedModeratedUsersCount();

    const countElement = document.getElementById("js-selected-moderated_users-count");
    const blockActions = document.getElementById("js-block-moderated_users-actions");
    const unblockActions = document.getElementById("js-unblock-moderated_users-actions");
    const unreportActions = document.getElementById("js-unreport-moderated_users-actions");

    if (selectedModeratedUsers === 0) {
      countElement.textContent = "";
      blockActions.classList.add("hide");
      unblockActions.classList.add("hide");
      unreportActions.classList.add("hide");
    } else {
      countElement.textContent = selectedModeratedUsers;
    }
  };

  const showBulkActionsButton = () => {
    if (selectedModeratedUsersCount() > 0) {
      document.getElementById("js-bulk-actions-button").classList.remove("hide");
    }
  };

  const hideBulkActionsButton = (force = false) => {
    const bulkActionsButton = document.getElementById("js-bulk-actions-button");
    const bulkActionsDropdown = document.getElementById("js-bulk-actions-dropdown");

    if (selectedModeratedUsersCount() === 0 || force) {
      bulkActionsButton.classList.add("hide");
      bulkActionsDropdown.classList.remove("is-open");
    }
  };

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
  };

  // Expose functions to make them available in .js.erb templates
  window.selectedModeratedUsersCountUpdate = selectedModeratedUsersCountUpdate;
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
          "block-moderated_users",
          "unreport-moderated_users",
          "unblock-moderated_users"
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

    // Select all checkboxes
    const moderatedUsersList = document.getElementById("moderated_users_bulk");
    if (moderatedUsersList !== null) {
      moderatedUsersList.addEventListener("change", function () {
        const isChecked = this.checked;
        const checkboxes = document.querySelectorAll(".js-check-all-moderated_users");

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

        selectedModeratedUsersCountUpdate();
      });
    }
    // moderated users checkbox change
    document.querySelector(".table-list").addEventListener("change", (event) => {
      if (!event.target.matches(".js-check-all-moderated_users")) {
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

      // If all individual checkboxes are checked, check the "select all" checkbox
      const allCheckboxes = Array.from(document.querySelectorAll(".js-check-all-moderated_users")).filter((checkboxItem) => checkboxItem.offsetParent !== null);
      const checkedCheckboxes = Array.from(document.querySelectorAll(".js-check-all-moderated_users:checked")).filter((checkboxItem) => checkboxItem.offsetParent !== null);

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

      document.querySelectorAll(`.js-moderated_user-id-${moderationId}`).forEach((input) => {
        input.checked = checked;
      });
      selectedModeratedUsersCountUpdate();
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
