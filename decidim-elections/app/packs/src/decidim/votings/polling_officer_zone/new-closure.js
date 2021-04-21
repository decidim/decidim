$(() => {
  $("#submit-verify-votes").addClass("disabled");

  $("#envelopes_result_total_ballots_count").on("keyup", function() {
    $("#modal-total-ballots-value").html($("#envelopes_result_total_ballots_count").val());
  });

  $("#envelopes_result_polling_officer_notes").on("keyup", function() {
    let modalPollingOfficerNotes = $("#envelopes_result_polling_officer_notes").val()

    if (modalPollingOfficerNotes.length > 0) {
      $("#btn-submit-from-modal").removeClass("disabled");
    } else {
      $("#btn-submit-from-modal").addClass("disabled");
    }
  });
});
