/* eslint-disable no-invalid-this */
/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["e"] }] */

$(() => {
  const selectedModeratedUsersCount = () => {
    return $(".table-list .js-check-all-moderated_users:checked").length;
  };

  const selectedModeratedUsersCountUpdate = function () {
    const selectedModeratedUsers = selectedModeratedUsersCount();

    if (selectedModeratedUsers === 0) {
      $("#js-selected-moderated_users-count").text("");
      $("#js-block-moderated_users-actions").addClass("hide");
      $("#js-unblock-moderated_users-actions").addClass("hide");
      $("#js-unreport-moderated_users-actions").addClass("hide");
    } else {
      $("#js-selected-moderated_users-count").text(selectedModeratedUsers);
    }
  };

  const showBulkActionsButton = function () {
    if (selectedModeratedUsersCount() > 0) {
      $("#js-bulk-actions-button").removeClass("hide");
    }
  };

  const hideBulkActionsButton = (force = false) => {
    if (selectedModeratedUsersCount() === 0 || force === true) {
      $("#js-bulk-actions-button").addClass("hide");
      $("#js-bulk-actions-dropdown").removeClass("is-open");
    }
  };

  const showOtherActionsButtons = function () {
    $("#js-other-actions-wrapper").removeClass("hide");
  };

  const hideOtherActionsButtons = function () {
    $("#js-other-actions-wrapper").addClass("hide");
  };

  const hideBulkActionForms = function () {
    $(".js-bulk-action-form").addClass("hide");
  };

  // Expose functions to make them available in .js.erb templates
  window.selectedModeratedUsersCountUpdate = selectedModeratedUsersCountUpdate;
  window.showBulkActionsButton = showBulkActionsButton;
  window.hideBulkActionsButton = hideBulkActionsButton;
  window.showOtherActionsButtons = showOtherActionsButtons;
  window.hideOtherActionsButtons = hideOtherActionsButtons;
  window.hideBulkActionForms = hideBulkActionForms;

  if ($(".js-bulk-action-form").length) {
    hideBulkActionForms();
    $("#js-bulk-actions-button").addClass("hide");

    $("#js-bulk-actions-dropdown ul li button").click(function (event) {
      $("#js-bulk-actions-dropdown").removeClass("is-open");
      hideBulkActionForms();

      let action = $(event.target).data("action");
      const panelActions = [
        "block-moderated_users",
        "unreport-moderated_users",
        "unblock-moderated_users"
      ];

      if (!action) {
        return;
      }

      if (panelActions.includes(action)) {
        $(`#js-form-${action}`).submit(function () {
          $(".layout-content > div[data-callout-wrapper]").html("");
        });

        $(`#js-${action}-actions`).removeClass("hide");
      } else {
        $(`#js-form-${action}`).submit(function () {
          $(".layout-content > div[data-callout-wrapper]").html("");
        });

        $(`#js-${action}-actions`).removeClass("hide");
        hideBulkActionsButton(true);
        hideOtherActionsButtons();
      }
    });

    // select all checkboxes
    $(".js-check-all").change(function () {
      $(".js-check-all-moderated_users").prop("checked", $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-moderated_users").closest("tr").addClass("selected");
        showBulkActionsButton();
      } else {
        $(".js-check-all-moderated_users").closest("tr").removeClass("selected");
        hideBulkActionsButton();
      }

      selectedModeratedUsersCountUpdate();
    });

    // moderated users checkbox change
    $(".table-list").on("change", ".js-check-all-moderated_users", function () {
      let moderationId = $(this).val();
      let checked = $(this).prop("checked");

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop("checked", false);
      }
      // check "select all" if all checkbox moderated_users are checked
      if (
        $(".js-check-all-moderated_users:checked").length ===
        $(".js-check-all-moderated_users").length
      ) {
        $(".js-check-all").prop("checked", true);
        showBulkActionsButton();
      }

      if ($(this).prop("checked")) {
        showBulkActionsButton();
        $(this).closest("tr").addClass("selected");
      } else {
        hideBulkActionsButton();
        $(this).closest("tr").removeClass("selected");
      }

      if ($(".js-check-all-moderated_users:checked").length === 0) {
        hideBulkActionsButton();
      }

      $(".js-bulk-action-form").find(`.js-moderated_user-id-${moderationId}`).prop("checked", checked);
      selectedModeratedUsersCountUpdate();
    });

    $(".js-cancel-bulk-action").on("click", function () {
      hideBulkActionForms();
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});
