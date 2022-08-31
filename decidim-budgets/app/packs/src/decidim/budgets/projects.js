$(() => {
  const $projects = $("#projects, #project");
  const $budgetSummaryTotal = $(".budget-progress_right_mark");
  const $budgetExceedModal = $("#budget-excess");
  const $budgetSummary = $(".budget-summary__progressbox");
  const $voteButton = $(".budget-vote-button");
  const totalAllocation = parseInt($budgetSummaryTotal.attr("data-total-allocation"), 10);

  const cancelEvent = (event) => {
    $(event.currentTarget).removeClass("loading-spinner");
    event.stopPropagation();
    event.preventDefault();
  };

  $voteButton.on("click", "span", () => {
    $(".budget-list__action").click();
  });

  $projects.on("click", ".budget-list__action", (event) => {
    const currentAllocation = parseInt($budgetSummary.attr("data-current-allocation"), 10);
    const $currentTarget = $(event.currentTarget);
    const projectAllocation = parseInt($currentTarget.attr("data-allocation"), 10);

    if (!$currentTarget.attr("data-open")) {
      $currentTarget.addClass("loading-spinner");
    }

    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if (($currentTarget.attr("data-add") === "true") && ((currentAllocation + projectAllocation) > totalAllocation)) {
      $budgetExceedModal.foundation("toggle");
      cancelEvent(event);
    }
  });

  // This hack moves the flash inside the layout (as in the redesign) only for the budgets page
  // Redesign: this should be removed after the redesign is finished
  const $budgetsToVote = $("#budgets-to-vote");
  const $votedBudgets = $("#voted-budgets");
  const $flash = $(".flash.success");
  if (($budgetsToVote.length || $votedBudgets.length) && $flash.length) {
    $("<div class=\"row\"></div>").prependTo($(".wrapper"));
    $flash.prependTo($(".wrapper .row:eq(0)"));
    $flash.css("margin-bottom", "1rem");
  }
});
