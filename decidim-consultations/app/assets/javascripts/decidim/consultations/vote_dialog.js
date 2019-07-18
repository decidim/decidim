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

  $("#confirm-vote-form").on("ajax:beforeSend", function() {
    $("#confirm-vote-form-loader,#confirm-vote-form").toggleClass("hide");
  });

  $("#confirm-vote-form").on("ajax:success", function() {
    voteConfirmDialog.foundation("close");
  });

  $("#confirm-vote-form").on("ajax:error", function(event) {
    const error = event && event.detail && event.detail[0].error;
    $("#vote-result-callout").addClass("alert").removeClass("hide warning");
    $("#vote-result-callout .callout-title").text($("#vote-result-callout").data("title-ko"));
    $("#vote-result-callout .callout-message").text(error || $("#vote-result-callout").data("message-ko"));
    $("#confirm-vote-form-loader,#confirm-vote-form").toggleClass("hide");
    voteConfirmDialog.foundation("close");
  });
});
