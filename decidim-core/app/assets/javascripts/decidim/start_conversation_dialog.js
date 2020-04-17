$(document).ready(function () {
  let addUsersConversationDialog = $("#user-conversations-add-modal"),
      button = $("#start-conversation-dialog-button");

  /* eslint no-unused-vars: 0 */
  if (addUsersConversationDialog.length) {
    let refreshUrl = addUsersConversationDialog.data("refresh-url");

    button.click(function () {
      addUsersConversationDialog.foundation("open");
    });
  }
});
