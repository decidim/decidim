/* eslint-disable no-invalid-this */
$(() => {
  const selectedResourcesCount = () => {
    return $(".table-list .js-check-all-resources:checked").length
  }

  const selectedResourcesNotPublishedAnswerCount = () => {
    return $(".table-list [data-published-state=false] .js-check-all-resources:checked").length
  }

  const selectedResourcesCountUpdate = () => {
    const selectedResources = selectedResourcesCount();
    const selectedResourcesNotPublishedAnswer = selectedResourcesNotPublishedAnswerCount();

    if (selectedResources === 0) {
      $("#js-selected-resources-count").text("")
    } else {
      $("#js-selected-resources-count").text(selectedResources);
    }

    if (selectedResources >= 2) {
      $('button[data-action="merge-resources"]').parent().show();
    } else {
      $('button[data-action="merge-resources"]').parent().hide();
    }

    if (selectedResourcesNotPublishedAnswer > 0) {
      $('button[data-action="publish-answers"]').parent().show();
      $("#js-form-publish-answers-number").text(selectedResourcesNotPublishedAnswer);
    } else {
      $('button[data-action="publish-answers"]').parent().hide();
    }
  }

  const showBulkActionsButton = () => {
    if (selectedResourcesCount() > 0) {
      $("#js-bulk-actions-button").removeClass("hide");
    }
  }

  const hideBulkActionsButton = (force = false) => {
    if (selectedResourcesCount() === 0 || force === true) {
      $("#js-bulk-actions-button").addClass("hide");
      $("#js-bulk-actions-dropdown").removeClass("is-open");
    }
  }

  const showOtherActionsButtons = () => {
    $("#js-other-actions-wrapper").removeClass("hide");
  }

  const hideOtherActionsButtons = () => {
    $("#js-other-actions-wrapper").addClass("hide");
  }

  const hideBulkActionForms = () => {
    $(".js-bulk-action-form").addClass("hide");
  }

  if ($("#js-bulk-actions-wrapper").length === 0) {
    return;
  }

  // Expose functions to make them available in .js.erb templates
  window.hideBulkActionForms = hideBulkActionForms;
  window.hideBulkActionsButton = hideBulkActionsButton;
  window.showOtherActionsButtons = showOtherActionsButtons;
  window.selectedResourcesCountUpdate = selectedResourcesCountUpdate;


  if ($(".js-bulk-action-form").length) {
    hideBulkActionForms();
    $("#js-bulk-actions-button").addClass("hide");

    $("#js-bulk-actions-dropdown li button").on("click", (event) => {
      event.preventDefault();
      let action = $(event.target).data("action");

      if (action) {
        $(`#js-form-${action}`).on("submit", () => {
          $(".layout-content > div[data-callout-wrapper]").html("");
        })

        $(`#js-${action}-actions`).removeClass("hide");
        hideBulkActionsButton(true);
        hideOtherActionsButtons();
      }
    })

    // select all checkboxes
    $(".js-check-all").on("change", function() {
      $(".js-check-all-resources").prop("checked", $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-resources").closest("tr").addClass("selected");
        showBulkActionsButton();
      } else {
        $(".js-check-all-resources").closest("tr").removeClass("selected");
        hideBulkActionsButton();
      }

      selectedResourcesCountUpdate();
    });

    // resource checkbox change
    $(".table-list").on("change", ".js-check-all-resources", function() {
      let resourceId = $(this).val()
      let checked = $(this).prop("checked")

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop("checked", false);
      }
      // check "select all" if all checkbox resources are checked
      if ($(".js-check-all-resources:checked").length === $(".js-check-all-resources").length) {
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

      if ($(".js-check-all-resources:checked").length === 0) {
        hideBulkActionsButton();
      }

      $(".js-bulk-action-form").find(`.js-resource-id-${resourceId}`).prop("checked", checked);
      selectedResourcesCountUpdate();
    });

    $(".js-cancel-bulk-action").on("click", () => {
      hideBulkActionForms()
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});
/* eslint-enable no-invalid-this */
