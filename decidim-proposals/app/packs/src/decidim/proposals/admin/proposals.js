/* eslint-disable no-invalid-this */
/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["e"] }] */

$(() => {
  const selectedProposalsCount = function() {
    return $(".table-list .js-check-all-proposal:checked").length
  }

  const selectedProposalsNotPublishedAnswerCount = function() {
    return $(".table-list [data-published-state=false] .js-check-all-proposal:checked").length
  }

  const selectedProposalsCountUpdate = function() {
    const selectedProposals = selectedProposalsCount();
    const selectedProposalsNotPublishedAnswer = selectedProposalsNotPublishedAnswerCount();
    if (selectedProposals === 0) {
      $("#js-selected-proposals-count").text("")
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

  const showOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").removeClass("hide");
  }

  const hideOtherActionsButtons = function() {
    $("#js-other-actions-wrapper").addClass("hide");
  }

  const hideBulkActionForms = function() {
    $(".js-bulk-action-form").addClass("hide");
  }

  // Expose functions to make them avaialble in .js.erb templates
  window.selectedProposalsCount = selectedProposalsCount;
  window.selectedProposalsNotPublishedAnswerCount = selectedProposalsNotPublishedAnswerCount;
  window.selectedProposalsCountUpdate = selectedProposalsCountUpdate;
  window.showBulkActionsButton = showBulkActionsButton;
  window.hideBulkActionsButton = hideBulkActionsButton;
  window.showOtherActionsButtons = showOtherActionsButtons;
  window.hideOtherActionsButtons = hideOtherActionsButtons;
  window.hideBulkActionForms = hideBulkActionForms;

  if ($(".js-bulk-action-form").length) {
    hideBulkActionForms();
    $("#js-bulk-actions-button").addClass("hide");

    $("#js-bulk-actions-dropdown ul li button").click(function(e) {
      e.preventDefault();
      let action = $(e.target).data("action");

      if (action) {
        $(`#js-form-${action}`).submit(function() {
          $(".layout-content > .callout-wrapper").html("");
        })

        $(`#js-${action}-actions`).removeClass("hide");
        hideBulkActionsButton(true);
        hideOtherActionsButtons();
      }
    })

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
