$(() => {
  const $projects = $("#projects, #project-item");
  const $budgetSummaryTotal = $(".budget-summary__progressbar-marks_right");
  const selectBudgetSummaryTotal = $budgetSummaryTotal.data("totalAllocation");
  const $budgetSummary = $(".budget-summary__progressbox");
  const $voteButton = $(".budget-vote-button");
  const totalAllocation = parseInt(selectBudgetSummaryTotal, 10);
  const additionSelectorButtons = document.querySelectorAll(".budget__list--header .button__pill")

  const cancelEvent = (event) => {
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

    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if (($currentTarget.attr("data-add") === "true") && ((currentAllocation + projectAllocation) > totalAllocation)) {
      window.Decidim.currentDialogs["budget-excess"].toggle()
      cancelEvent(event);
    }
  });

  additionSelectorButtons.forEach(function(button) {
    button.addEventListener("click", function(event) {
      additionSelectorButtons.forEach(function(element) {
        element.classList.remove("button__pill--active")
      })
      event.currentTarget.classList.add("button__pill--active")
    })
  });
});
