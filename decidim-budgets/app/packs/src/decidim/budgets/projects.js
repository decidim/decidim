$(() => {
  const $projects = $("#projects, #project");
  const $budgetSummaryTotal = $(".budget-summary__total");
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
});
