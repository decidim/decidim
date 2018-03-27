$(document).ready(function () {
  'use strict';

  var voteDialog = $('#question-vote-modal'),
      voteConfirmDialog = $('#question-vote-confirm-modal'),
      responseButtons = $('.response-title'),
      buttonChange = $('#question-vote-confirm-modal-button-change'),
      buttonConfirm = $('#question-vote-confirm-modal-confirm'),
      button = $('#vote_button');

  if (voteDialog.length && button.length) {
    button.click(function () {
      voteDialog.foundation('open');
    });
  }

  if (voteDialog.length && responseButtons.length && voteConfirmDialog.length) {
    responseButtons.click(function () {
      $('#question-vote-confirm-modal-question-title').text($(this).text());
      $('#decidim_consultations_response_id').val($(this).data('response-id'));

      voteDialog.foundation('close');
      voteConfirmDialog.foundation('open');
    });
  }

  if (buttonChange.length && voteDialog.length && voteConfirmDialog.length) {
    buttonChange.click(function() {
      voteConfirmDialog.foundation('close');
      voteDialog.foundation('open');
    });
  }

  $('#confirm-vote-form').on("ajax:success", function() {
    voteConfirmDialog.foundation('close');
  });
});
