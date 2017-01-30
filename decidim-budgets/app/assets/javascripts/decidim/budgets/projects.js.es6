// = require_self

$(() => {
  const $projects = $('#projects');
  const $budgetSummaryTotal = $('.budget-summary__total');
  const $budgetExceedModal = $('#budget-excess');

  const totalBudget = $budgetSummaryTotal.data('total-budget');

  $projects.on('click', '.budget--list__action', (event) => {
    const currentBudget = $('.budget-summary__progressbox').data('current-budget');
    const $currentTarget = $(event.currentTarget);
    const projectBudget = $currentTarget.data('budget');

    if ($currentTarget.data('add') && ((currentBudget + projectBudget) > totalBudget)) {
      $budgetExceedModal.foundation('toggle');
      event.stopPropagation();
      event.preventDefault();
    }
  });
});
