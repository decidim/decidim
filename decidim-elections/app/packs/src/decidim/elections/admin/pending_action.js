import { Client } from "@decidim/decidim-bulletin_board";
import { reportingErrors } from "src/decidim/reporting_errors";

$(reportingErrors(() => {
  const $form = $("form.step");
  const $pendingAction = $form.find("#pending_action");
  const bulletinBoardClient = new Client({
    apiEndpointUrl: $pendingAction.data("apiEndpointUrl")
  });
  const messageId = $pendingAction.data("messageId");

  bulletinBoardClient.waitForPendingMessageToBeProcessed(messageId).then(() => {
    $form.trigger("submit");
  });
}));
