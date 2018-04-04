/* eslint-disable no-invalid-this */

$(document).ready(function () {
  let button = $("#vote_button"),
      buttonChange = $("#question-vote-confirm-modal-button-change"),
      responseButtons = $(".response-title"),
      voteConfirmDialog = $("#question-vote-confirm-modal"),
      voteDialog = $("#question-vote-modal");

  if (voteDialog.length && button.length) {
    button.click(function () {
      voteDialog.foundation("open");
    });
  }

  if (voteDialog.length && responseButtons.length && voteConfirmDialog.length) {
    responseButtons.click(function () {
      $("#question-vote-confirm-modal-question-title").text($(this).text());
      $("#decidim_consultations_response_id").val($(this).data("response-id"));

      voteDialog.foundation("close");
      voteConfirmDialog.foundation("open");
    });
  }

  if (buttonChange.length && voteDialog.length && voteConfirmDialog.length) {
    buttonChange.click(function() {
      voteConfirmDialog.foundation("close");
      voteDialog.foundation("open");
    });
  }

  $("#confirm-vote-form").on("ajax:success", function() {
    voteConfirmDialog.foundation("close");
  });
});
