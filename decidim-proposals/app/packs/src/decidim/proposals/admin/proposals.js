/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["e"] }] */

import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("turbo:load", () => {
  const selectedProposalsCount = function() {
    return $(".table-list .js-check-all-proposal:checked").length;
  };

  const selectedProposalsNotPublishedAnswerCount = function() {
    return $(".table-list [data-published-state=false] .js-check-all-proposal:checked").length;
  };

  const selectedProposalsAllowsAnswerCount = function() {
    return $(".table-list [data-allow-answer=true] .js-check-all-proposal:checked").length;
  };

  const selectedProposalsCountUpdate = function() {
    const selectedProposals = selectedProposalsCount();
    const selectedProposalsNotPublishedAnswer = selectedProposalsNotPublishedAnswerCount();
    const allowAnswerProposals = selectedProposalsAllowsAnswerCount();

    if (selectedProposals === 0) {
      $("#js-selected-proposals-count").text("");
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
  };

  const resetForms = function() {
    document.querySelectorAll(
      "#js-bulk-actions-dropdown button[data-action]"
    ).forEach((button) => {
      const action = button.dataset.action;

      if (!action) {
        return;
      }

      const form = document.querySelector(
        `#js-form-${action}`
      );

      if (form) {
        form.reset();
      }
    });
  };

  window.selectedProposalsCount = selectedProposalsCount;
  window.selectedProposalsNotPublishedAnswerCount = selectedProposalsNotPublishedAnswerCount;
  window.selectedProposalsCountUpdate = selectedProposalsCountUpdate;
  window.resetForms = resetForms;

  /*
   * The unified bulk-actions controller handles the actual
   * checkbox mechanics. These only recalculate the
   * proposal-specific action availability afterward.
   */

  $(".js-check-all").off(
    "change.proposalBulkActions"
  ).on(
    "change.proposalBulkActions", () => {
      // Wait for bulk-actions sync before recalculating.
      queueMicrotask(selectedProposalsCountUpdate);
    });

  $(".table-list").off(
    "change.proposalBulkActions",
    ".js-check-all-proposal"
  ).on(
    "change.proposalBulkActions",
    ".js-check-all-proposal",
    () => {
      // Wait for bulk-actions sync before recalculating.
      queueMicrotask(selectedProposalsCountUpdate);
    }
  );

  selectedProposalsCountUpdate();
});

document.addEventListener("turbo:load", () => {
  const evaluatorMultiselectContainers = document.querySelectorAll(
    ".js-evaluator-multiselect"
  );

  evaluatorMultiselectContainers.forEach((container) => {
    if (container.tomselect) {
      return;
    }

    const config = {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true
    };
    // eslint-disable-next-line no-new
    new TomSelect(container, config);
  });
});
