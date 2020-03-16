$(document).ready(function () {
  let button = $("#start-conversation-dialog-button"),
      addUsersConversationDialog = $("#user-conversations-add-modal");

  if (addUsersConversationDialog.length) {
    let refreshUrl = addUsersConversationDialog.data("refresh-url");

    button.click(function () {
      addUsersConversationDialog.foundation('open');
    });
  }
});
