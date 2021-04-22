$(() => {
  const $submitBtn = $("#submit-verify-votes");
  const $modalBtn = $("#btn-modal-closure-count-error");
  const $totalBallotsInput = $("#envelopes_result_total_ballots_count");
  const $electionVotesInput = $("#envelopes_result_election_votes_count");

  const checkValues = () => {
    const totalBallotsInputValue = parseInt($totalBallotsInput.val(), 10);
    const electionVotesInputValue = parseInt($electionVotesInput.val(), 10);


    if (totalBallotsInputValue === electionVotesInputValue) {
      $submitBtn.removeClass("disabled hide");
      $modalBtn.addClass("hide");
    } else {
      $submitBtn.addClass("hide");
      $modalBtn.removeClass("hide");
    }
  };

  $totalBallotsInput.on("blur", checkValues);

  $("#submit-verify-votes").addClass("disabled");

  $totalBallotsInput.on("keyup", function() {
    $("#modal-total-ballots-value").html(parseInt($totalBallotsInput.val(), 10));
  });

  $("#envelopes_result_polling_officer_notes").on("keyup", function() {
    let modalPollingOfficerNotes = $("#envelopes_result_polling_officer_notes").val()

    $("#btn-submit-from-modal").toggleClass("disabled", !modalPollingOfficerNotes.trim());
  });
});
