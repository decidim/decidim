$(() => {
  const $submitBtn = $("#submit-verify-votes");
  const $modalBtn = $("#btn-modal-closure-count-error");
  const $totalBallotsInput = $("#envelopes_result_total_ballots_count");
  const $electionVotesInput = $("#envelopes_result_election_votes_count");
  const $formNotes = $("#envelopes_result_polling_officer_notes");
  const $modalNotes = $("#modal-polling-officer-notes");

  const checkValues = () => {
    const totalBallotsInputValue = parseInt($totalBallotsInput.val(), 10);
    const electionVotesInputValue = parseInt($electionVotesInput.val(), 10);

    if (totalBallotsInputValue === electionVotesInputValue) {
      $submitBtn.find("button").attr("disabled", false);
      $submitBtn.attr("hidden", false);
      $modalBtn.attr("hidden", true);
    } else {
      $submitBtn.attr("hidden", true);
      $modalBtn.attr("hidden", false);
      $("#modal-total-ballots-value").html(parseInt($totalBallotsInput.val(), 10));
    }
  };
  checkValues();

  $totalBallotsInput.on("blur", checkValues);

  $totalBallotsInput.on("keyup", () => {
    $formNotes.val("");
    $modalNotes.val("");
  });

  $modalNotes.on("keyup", () => {
    $("#btn-submit-from-modal").attr("disabled", !$modalNotes.val().trim());
  });

  $modalNotes.on("change", () => {
    $formNotes.val($modalNotes.val());
  });
});
