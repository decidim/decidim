$(() => {
  $("#submit-verify-votes").addClass("disabled");

  $("#ballots_result_total_ballots_count").on("keyup", function() {
    $("#submit-verify-votes").removeClass("disabled");
    $("#modal-total-ballots-value").html($("#ballots_result_total_ballots_count").val());
  });

  $("#ballots_result_polling_officer_notes").on("keyup", function() {
    let modalPollingOfficerNotes = $("#ballots_result_polling_officer_notes").val()

    if (modalPollingOfficerNotes.length > 0) {
      $("#btn-submit-from-modal").removeClass("disabled");
    } else {
      $("#btn-submit-from-modal").addClass("disabled");
    }
  });
});
