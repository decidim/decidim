$(document).ready(function () {
  'use strict';

  var userIdentitiesDialog = $('#user-identities'),
      button = $('#select-identity-button'),
      refreshUrl;

  if (userIdentitiesDialog.length) {
    refreshUrl = userIdentitiesDialog.data('refresh-url');

    button.click(function () {
      $.ajax(refreshUrl).done(function(response){
        userIdentitiesDialog.html(response).foundation('open');
      });
    });
  }
});