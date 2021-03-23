/* eslint-disable no-console */
// = require decidim/bulletin_board/decidim-bulletin_board
// = require decidim/bulletin_board/decidim-bulletin_board

$(async () => {
  const $castingVoteWrapper = $(".casting-vote-wrapper");
  const { Client } = decidimBulletinBoard;

  const bulletinBoardClient = new Client({
    apiEndpointUrl: $castingVoteWrapper.data("apiEndpointUrl"),
  });
  const messageId = $castingVoteWrapper.data("messageId");
  const encryptedDataHash = $castingVoteWrapper.data("encryptedDataHash");
  const electionUniqueId = $castingVoteWrapper.data("electionUniqueId");

  const pendingMessage = await bulletinBoardClient.waitForPendingMessageToBeProcessed(
    messageId
  );

  if (pendingMessage.status != "accepted") {
    window.location.reload();
  }

  bulletinBoardClient
    .getLogEntry({
      electionUniqueId: electionUniqueId,
      contentHash: encryptedDataHash,
    })
    .then((result) => {
      if (result) {
        $("form.update_vote_status").trigger("submit");
      } else {
        alert("error");
      }
    });
});
