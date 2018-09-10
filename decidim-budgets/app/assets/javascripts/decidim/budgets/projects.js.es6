// = require ./progressFixed
// = require_self

$(() => {
  const $projects = $("#projects, #project");
  const $budgetSummaryTotal = $(".budget-summary__total");
  const $budgetExceedModal = $("#limit-excess");

  const totalBudget = parseInt($budgetSummaryTotal.attr("data-total-budget"), 10);
  const totalProjects = parseInt($budgetSummaryTotal.attr("data-total-projects"), 10);

  const cancelEvent = (event) => {
    event.stopPropagation();
    event.preventDefault();
  };

  $projects.on("click", ".budget--list__action", (event) => {
    const currentBudget = parseInt($(".budget-summary__progressbox").attr("data-current-budget"), 10);
    const currentProjects = parseInt($(".budget-summary__progressbox").attr("data-current-projects"), 10);
    const perProject = $budgetSummaryTotal.attr("data_per_project");
    const $currentTarget = $(event.currentTarget);
    const projectBudget = parseInt($currentTarget.attr("data-budget"), 10);
    if ($currentTarget.attr("data-add") && (currentProjects === totalProjects) && perProject){
      $budgetExceedModal.foundation("toggle");
      cancelEvent(event);
    } else if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if ($currentTarget.attr("data-add") && ((currentBudget + projectBudget) > totalBudget) && perProject === "false") {
      $budgetExceedModal.foundation("toggle");
      cancelEvent(event);
    }
  });
});
