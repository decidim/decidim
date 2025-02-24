/* eslint-disable no-invalid-this */
/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["e"] }] */

import TomSelect from "tom-select/dist/cjs/tom-select.popular";

$(() => {
  let isMergeProposalsClicked = false;
  $('button[data-action="merge-proposals"]').on("click", function() {
    isMergeProposalsClicked = true;
  });

  const selectedProposalsCount = function() {
    return $(".table-list .js-check-all-proposal:checked").length
  }

  const selectedProposalsNotPublishedAnswerCount = function() {
    return $(".table-list [data-published-state=false] .js-check-all-proposal:checked").length
  }

  const selectedProposalsAllowsAnswerCount = function() {
    return $(".table-list [data-allow-answer=true] .js-check-all-proposal:checked").length
  }

  const selectedProposalsCountUpdate = function() {
    const selectedProposals = selectedProposalsCount();
    const selectedProposalsNotPublishedAnswer = selectedProposalsNotPublishedAnswerCount();
    const allowAnswerProposals = selectedProposalsAllowsAnswerCount();

    if (selectedProposals === 0) {
      $("#js-selected-proposals-count").text("")
      $("#js-assign-proposals-to-evaluator-actions").addClass("hide");
      $("#js-unassign-proposals-from-evaluator-actions").addClass("hide");
      $("#js-taxonomy-change-proposals-actions").addClass("hide");
    } else {
      $("#js-selected-proposals-count").text(selectedProposals);
    }

    if (selectedProposals >= 2) {
      $('button[data-action="merge-proposals"]').parent().show();
    } else {
      $('button[data-action="merge-proposals"]').parent().hide();
    }

    if (selectedProposalsNotPublishedAnswer > 0) {
      $('button[data-action="publish-answers"]').parent().show();
      $("#js-form-publish-answers-number").text(selectedProposalsNotPublishedAnswer);
    } else {
      $('button[data-action="publish-answers"]').parent().hide();
    }

    if (allowAnswerProposals > 0) {
      $('button[data-action="apply-answer-template"]').parent().show();
      $("#js-form-apply-answer-template-number").text(allowAnswerProposals);
    } else {
      $('button[data-action="apply-answer-template"]').parent().hide();
    }
  }

  const showBulkActionsButton = function() {
    if (selectedProposalsCount() > 0) {
      $("#js-bulk-actions-button").removeClass("hide");
    }
  }

  const hideBulkActionsButton = function(force = false) {
    if (selectedProposalsCount() === 0 || force === true) {
      $("#js-bulk-actions-button").addClass("hide");
      $("#js-bulk-actions-dropdown").removeClass("is-open");
    }
  }

  const resetForms = function() {
    $("#js-bulk-actions-dropdown button").each(function() {
      $(`#js-form-${$(this).data("action")}`)[0].reset();
    })
  }

  const showOtherActionsButtons = function() {
    if (isMergeProposalsClicked) {
      return;
    }
    $("#js-other-actions-wrapper").removeClass("hide");
  }

  const hideOtherActionsButtons = function() {
    if (isMergeProposalsClicked) {
      return;
    }
    $("#js-other-actions-wrapper").addClass("hide");
  }

  const hideBulkActionForms = function() {
    $(".js-bulk-action-form").addClass("hide");
  }

  // Expose functions to make them available in .js.erb templates
  window.selectedProposalsCount = selectedProposalsCount;
  window.selectedProposalsNotPublishedAnswerCount = selectedProposalsNotPublishedAnswerCount;
  window.selectedProposalsCountUpdate = selectedProposalsCountUpdate;
  window.showBulkActionsButton = showBulkActionsButton;
  window.hideBulkActionsButton = hideBulkActionsButton;
  window.showOtherActionsButtons = showOtherActionsButtons;
  window.hideOtherActionsButtons = hideOtherActionsButtons;
  window.hideBulkActionForms = hideBulkActionForms;
  window.resetForms = resetForms;

  if ($(".js-bulk-action-form").length) {
    hideBulkActionForms();
    $("#js-bulk-actions-button").addClass("hide");

    $("#js-bulk-actions-dropdown ul li button").click(function (e) {
      $("#js-bulk-actions-dropdown").removeClass("is-open");
      hideBulkActionForms();

      let action = $(e.target).data("action");
      const panelActions = [
        "assign-proposals-to-evaluator",
        "unassign-proposals-from-evaluator",
        "taxonomy-change-proposals"
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
        hideBulkActionsButton(!isMergeProposalsClicked);
        hideOtherActionsButtons();
      }
    });

    // select all checkboxes
    $(".js-check-all").change(function() {
      $(".js-check-all-proposal").prop("checked", $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-proposal").closest("tr").addClass("selected");
        showBulkActionsButton();
      } else {
        $(".js-check-all-proposal").closest("tr").removeClass("selected");
        hideBulkActionsButton();
      }

      selectedProposalsCountUpdate();
    });

    // proposal checkbox change
    $(".table-list").on("change", ".js-check-all-proposal", function (e) {
      let proposalId = $(this).val()
      let checked = $(this).prop("checked")

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop("checked", false);
      }
      // check "select all" if all checkbox proposals are checked
      if ($(".js-check-all-proposal:checked").length === $(".js-check-all-proposal").length) {
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

      if ($(".js-check-all-proposal:checked").length === 0) {
        hideBulkActionsButton();
      }

      $(".js-bulk-action-form").find(`.js-proposal-id-${proposalId}`).prop("checked", checked);
      selectedProposalsCountUpdate();
    });

    $(".js-cancel-bulk-action").on("click", function (e) {
      hideBulkActionForms()
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const evaluatorMultiselectContainers = document.querySelectorAll(
    ".js-evaluator-multiselect"
  );

  evaluatorMultiselectContainers.forEach((container) => {
    const config = {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true
    };

    return new TomSelect(container, config);
  });
});
