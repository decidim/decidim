import { Client } from "@decidim/decidim-bulletin_board";

$(async () => {
  const $castingVoteWrapper = $(".casting-vote-wrapper");

  const bulletinBoardClient = new Client({
    apiEndpointUrl: $castingVoteWrapper.data("apiEndpointUrl")
  });
  const messageId = $castingVoteWrapper.data("messageId");

  await bulletinBoardClient.waitForPendingMessageToBeProcessed(messageId);

  $("form.update_vote_status").trigger("submit");
});
