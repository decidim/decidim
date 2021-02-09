// = require decidim/bulletin_board/decidim-bulletin_board

$(() => {
  const { Client } = decidimBulletinBoard;
  const $form = $("form.step");
  const $pendingAction = $form.find("#pending_action")
  const bulletinBoardClient = new Client({
    apiEndpointUrl: $pendingAction.data("apiEndpointUrl")
  });
  const messageId = $pendingAction.data("messageId")

  bulletinBoardClient.waitForPendingMessageToBeProcessed(messageId).then(() => {
    $form.submit();
  });
});

