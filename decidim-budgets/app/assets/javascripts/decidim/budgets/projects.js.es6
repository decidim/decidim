// = require ./progressFixed
// = require_self

$(() => {
  const $projects = $("#projects, #project");
  const $budgetSummaryTotal = $(".budget-summary__total");
  const $budgetExceedModal = $("#budget-excess");
  const $budgetSummary = $(".budget-summary__progressbox");
  const totalBudget = parseInt($budgetSummaryTotal.attr("data-total-budget"), 10);

  const cancelEvent = (event) => {
    event.stopPropagation();
    event.preventDefault();
  };

  $projects.on("click", ".budget-list__action", (event) => {
    const currentBudget = parseInt($budgetSummary.attr("data-current-budget"), 10);
    const $currentTarget = $(event.currentTarget);
    const projectBudget = parseInt($currentTarget.attr("data-budget"), 10);

    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);

    } else if (($currentTarget.attr("data-add") === "true") && ((currentBudget + projectBudget) > totalBudget)) {
      $budgetExceedModal.foundation("toggle");
      cancelEvent(event);
    }
  });

  if ($("#order-progress [data-toggle=budget-confirm]").length > 0) {
    const safeUrl = $(".budget-summary").attr("data-safe-url");
    $(document).on("click", "a", (event) => {
      window.exitUrl = event.currentTarget.href;
    });
    $(document).on("submit", "form", (event) => {
      window.exitUrl = event.currentTarget.action;
    });

    window.onbeforeunload = () => {
      const currentBudget = parseInt($budgetSummary.attr("data-current-budget"), 10);
      const exitUrl = window.exitUrl;
      window.exitUrl = null;

      if (currentBudget === 0 || (exitUrl && exitUrl.startsWith(safeUrl))) {
        return null;
      }

      return "";
    }
  }
});
