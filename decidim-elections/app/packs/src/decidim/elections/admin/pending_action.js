import { Client } from "@codegram/decidim-bulletin_board";

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
