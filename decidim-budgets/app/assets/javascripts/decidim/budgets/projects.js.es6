// = require ./progressFixed
// = require_self

$(() => {
  const $projects = $('#projects, #project');
  const $budgetSummaryTotal = $('.budget-summary__total');
  const $budgetExceedModal = $('#budget-excess');

  const totalBudget = $budgetSummaryTotal.data('total-budget');

  const cancelEvent = (event) => {
    event.stopPropagation();
    event.preventDefault();
  };

  $projects.on('click', '.budget--list__action', (event) => {
    const currentBudget = $('.budget-summary__progressbox').data('current-budget');
    const $currentTarget = $(event.currentTarget);
    const projectBudget = $currentTarget.data('budget');

    if ($currentTarget.attr('disabled')) {
      cancelEvent(event);

    } else if ($currentTarget.data('add') && ((currentBudget + projectBudget) > totalBudget)) {
      $budgetExceedModal.foundation('toggle');
      cancelEvent(event);
    }
  });
});
