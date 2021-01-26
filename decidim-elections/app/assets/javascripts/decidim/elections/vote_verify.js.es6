/* eslint-disable require-jsdoc, prefer-template, func-style, id-length, no-use-before-define, init-declarations, no-invalid-this */
/* eslint no-unused-vars: ["error", { "args": "none" }] */
// = require decidim/bulletin_board/decidim-bulletin_board

$(() => {
  const { Client } = decidimBulletinBoard;
  const $voteVerifyWrapper = $(".vote-verify-wrapper");
  const $verifySubmitButton = $voteVerifyWrapper.find("a.focus__next.confirm");

  let $formData = $voteVerifyWrapper.find(".vote-identifier");

  function initStep() {
    toggleVerifyButton();
    onVoteIdentifierChange();
  }

  initStep()

  function onVoteIdentifierChange() {
    $formData.on("keyup input", (event) => {
      toggleVerifyButton();
      hideSuccessCallout();
      hideErrorCallout();
    });
  }

  function toggleVerifyButton() {
    if ($formData.val().length > 5) {
      $($verifySubmitButton).removeClass("disabled")
    } else {
      $($verifySubmitButton).addClass("disabled")
    }
  }

  function hideSuccessCallout() {
    $voteVerifyWrapper.find(".verify-vote-success").addClass("hide");
  }

  function hideErrorCallout() {
    $voteVerifyWrapper.find(".verify-vote-error").addClass("hide");
  }

  $verifySubmitButton.on("click", (event) => {
    event.preventDefault();
    verifyVoteIdentifier();
  });

  function verifyVoteIdentifier() {
    const bulletinBoardClient = new Client({
      apiEndpointUrl: $voteVerifyWrapper.data("apiEndpointUrl"),
      wsEndpointUrl: $voteVerifyWrapper.data("websocketUrl")
    });

    bulletinBoardClient.getLogEntry({
      electionUniqueId: $voteVerifyWrapper.data("electionUniqueId"),
      contentHash: $formData.val()
    }).then((result) => {
      if (result) {
        hideErrorCallout();
        $voteVerifyWrapper.find(".verify-vote-success").removeClass("hide");
      } else {
        hideSuccessCallout();
        $voteVerifyWrapper.find(".verify-vote-error").removeClass("hide");
      }
    })
  }

  $(document).on("on.zf.toggler", (event) => {
    initStep()
  });
});
