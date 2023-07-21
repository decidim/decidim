/* eslint-disable require-jsdoc, prefer-template, func-style, id-length, no-use-before-define, init-declarations, no-invalid-this */
/* eslint no-unused-vars: ["error", { "args": "none" }] */

import { Client } from "@decidim/decidim-bulletin_board";

$(() => {
  const $voteVerifyWrapper = $("#verify-vote-wrapper");

  if (!$voteVerifyWrapper.length) {
    return
  }

  const $verifySubmitButton = $voteVerifyWrapper.find("[type=submit]");

  let $formData = $voteVerifyWrapper.find(".vote-identifier");

  function initStep() {
    toggleVerifyButton();
    onVoteIdentifierChange();
  }

  initStep();

  function onVoteIdentifierChange() {
    $formData.on("keyup input", (event) => {
      toggleVerifyButton();
      hideSuccessCallout();
      hideErrorCallout();
    });
  }

  function toggleVerifyButton() {
    if ($formData.val().length > 5) {
      $($verifySubmitButton).removeClass("disabled");
    } else {
      $($verifySubmitButton).addClass("disabled");
    }
  }

  function hideSuccessCallout() {
    $voteVerifyWrapper.find("#verify-vote-success").attr("hidden", true);
  }

  function hideErrorCallout() {
    $voteVerifyWrapper.find("#verify-vote-error").attr("hidden", true);
  }

  $verifySubmitButton.on("click", (event) => {
    event.preventDefault();
    verifyVoteIdentifier();
  });

  function verifyVoteIdentifier() {
    const bulletinBoardClient = new Client({
      apiEndpointUrl: $voteVerifyWrapper.data("apiEndpointUrl")
    });

    bulletinBoardClient.
      getLogEntry({
        electionUniqueId: $voteVerifyWrapper.data("electionUniqueId"),
        contentHash: $formData.val()
      }).
      then((result) => {
        if (result) {
          hideErrorCallout();
          $voteVerifyWrapper.find("#verify-vote-success").attr("hidden", false);
        } else {
          hideSuccessCallout();
          $voteVerifyWrapper.find("#verify-vote-error").attr("hidden", false);
        }
      });
  }

  $(document).on("on.zf.toggler", (event) => {
    initStep();
  });
});
