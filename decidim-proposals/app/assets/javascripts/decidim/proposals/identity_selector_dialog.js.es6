/**
 * Makes the #select-identity-button to open a popup for the user to
 * select with which identity he wants to perform an action.
 */
$(document).ready(function () {

  let button = $('#select-identity-button'),
      refreshUrl= null,
      userIdentitiesDialog = $('#user-identities');

  if (userIdentitiesDialog.length) {
    refreshUrl = userIdentitiesDialog.data('refresh-url');

    button.click(function () {
      $.ajax(refreshUrl).done(function(response) {
        userIdentitiesDialog.html(response).foundation('open');
      });
    });
  }
});
