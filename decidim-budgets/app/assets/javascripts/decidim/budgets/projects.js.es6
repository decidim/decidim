// = require ./progressFixed
// = require_self

$(() => {
  const $projects = $("#projects, #project");
  const $budgetSummaryTotal = $(".budget-summary__total");
  const $budgetExceedModal = $("#budget-excess");

  const totalBudget = parseInt($budgetSummaryTotal.attr("data-total-budget"), 10);

  const cancelEvent = (event) => {
    event.stopPropagation();
    event.preventDefault();
  };

  $projects.on("click", ".budget--list__action", (event) => {
    const currentBudget = parseInt($(".budget-summary__progressbox").attr("data-current-budget"), 10);
    const $currentTarget = $(event.currentTarget);
    const projectBudget = parseInt($currentTarget.attr("data-budget"), 10);

    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if ($currentTarget.attr("data-add")) {
      if ((currentBudget + projectBudget) > totalBudget) {
        $budgetExceedModal.foundation("toggle");
        cancelEvent(event);
      } else if ((currentBudget + projectBudget) === totalBudget) {
        $(".budget--list__action[data-add]").attr("disabled", "disabled");
        $currentTarget.removeAttr("disabled");
      }
    } else {
      $(".budget--list__action[data-add]").removeAttr("disabled");
    }
  });
});
