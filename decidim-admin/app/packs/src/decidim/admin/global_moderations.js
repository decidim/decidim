/* eslint-disable no-invalid-this */

$(() => {
  const selectedModerationsCount = () => {
    return $(".table-list .js-check-all-moderations:checked").length;
  };

  const selectedModerationsCountUpdate = function () {
    const selectedModerations = selectedModerationsCount();

    if (selectedModerations === 0) {
      $("#js-selected-moderations-count").text("");
    } else {
      $("#js-selected-moderations-count").text(selectedModerations);
    }
  };

  const showBulkActionsButton = function () {
    if (selectedModerationsCount() > 0) {
      $("#js-bulk-actions-button").removeClass("hide");
    }
  };

  const hideBulkActionsButton = (force = false) => {
    if (selectedModerationsCount() === 0 || force === true) {
      $("#js-bulk-actions-button").addClass("hide");
      $("#js-bulk-actions-dropdown").removeClass("is-open");
    }
  }

  const showOtherActionsButtons = function () {
    $("#js-other-actions-wrapper").removeClass("hide");
  };

  const hideOtherActionsButtons = function () {
    $("#js-other-actions-wrapper").addClass("hide");
  };

  const hideBulkActionForms = function() {
    $(".js-bulk-action-form").addClass("hide");
  }

  // Expose functions to make them available in .js.erb templates
  window.selectedModerationsCountUpdate = selectedModerationsCountUpdate;
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
        "hide-global-moderations",
        "unreport-global-moderations",
        "unhide-global-moderations"
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
      $(".js-check-all-moderations").prop("checked", $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-moderations").closest("tr").addClass("selected");
        showBulkActionsButton();
      } else {
        $(".js-check-all-moderations").closest("tr").removeClass("selected");
        hideBulkActionsButton();
      }

      selectedModerationsCountUpdate();
    });

    // moderation checkbox change
    $(".table-list").on("change", ".js-check-all-moderations", function () {
      let moderationId = $(this).val();
      let checked = $(this).prop("checked");

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop("checked", false);
      }
      // check "select all" if all checkbox moderations are checked
      if (
        $(".js-check-all-moderations:checked").length ===
        $(".js-check-all-moderations").length
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

      if ($(".js-check-all-moderations:checked").length === 0) {
        hideBulkActionsButton();
      }

      $(".js-bulk-action-form").find(`.js-moderation-id-${moderationId}`).prop("checked", checked);
      selectedModerationsCountUpdate();
    });

    $(".js-cancel-bulk-action").on("click", function () {
      hideBulkActionForms();
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});
