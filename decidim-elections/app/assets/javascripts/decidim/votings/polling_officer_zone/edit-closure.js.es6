$(() => {
  const $validBallotsInput = $("#closure_result__ballot_results__valid_ballots_count");
  const $blankBallotsInput = $("#closure_result__ballot_results__blank_ballots_count");
  const $nullBallotsInput = $("#closure_result__ballot_results__null_ballots_count");

  const checkTotals = () => {
    const totalBallots = $("#closure_result-total-ballots").data("total-ballots");
    const validBallotsCount = parseInt($validBallotsInput.val(), 10);
    const blankBallotsCount = parseInt($blankBallotsInput.val(), 10);
    const nullBallotsCount = parseInt($nullBallotsInput.val(), 10);

    let recount = validBallotsCount + blankBallotsCount + nullBallotsCount

    if (recount === totalBallots) {
      $("#submit-ballot-recount").removeClass("hide");
      $("#btn-modal-closure-results-count-error").addClass("hide");
    } else {
      $("#submit-ballot-recount").addClass("hide");
      $("#btn-modal-closure-results-count-error").removeClass("hide");
    }
  };

  $validBallotsInput.on("blur", checkTotals);
  $blankBallotsInput.on("blur", checkTotals);
  $nullBallotsInput.on("blur", checkTotals);
});
