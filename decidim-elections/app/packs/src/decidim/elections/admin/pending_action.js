// show a message to the user if comunication is lost
import "src/decidim/elections/error_handler";
import { Client } from "@decidim/decidim-bulletin_board";

$(() => {
  const $form = $("form.step");
  const $pendingAction = $form.find("#pending_action");
  const bulletinBoardClient = new Client({
    apiEndpointUrl: $pendingAction.data("apiEndpointUrl")
  });
  const messageId = $pendingAction.data("messageId");

  bulletinBoardClient.waitForPendingMessageToBeProcessed(messageId).then(() => {
    $form.trigger("submit");
  });
});
