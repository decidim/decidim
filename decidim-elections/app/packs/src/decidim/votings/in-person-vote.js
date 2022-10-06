// show a message to the user if comunication is lost
import "src/decidim/elections/broken_promises_handler";

import { Client } from "@decidim/decidim-bulletin_board";

$(async () => {
  const $inPersonVoteWrapper = $(".in-person-vote-wrapper");
  if ($inPersonVoteWrapper.length > 0) {
    const bulletinBoardClient = new Client({
      apiEndpointUrl: $inPersonVoteWrapper.data("apiEndpointUrl")
    });
    const messageId = $inPersonVoteWrapper.data("messageId");

    await bulletinBoardClient.waitForPendingMessageToBeProcessed(messageId);

    $("form.update_vote_status").trigger("submit");
  }

  $(".js-verify-document").on("click", () => {
    $("#verify-document").hide();
    $("#complete-voting").removeClass("hide");
  });
});
