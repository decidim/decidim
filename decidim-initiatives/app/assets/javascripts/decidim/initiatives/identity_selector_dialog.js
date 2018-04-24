$(document).ready(function () {
  let button = $("#select-identity-button"),
      userIdentitiesDialog = $("#user-identities");

  if (userIdentitiesDialog.length) {
    let refreshUrl = userIdentitiesDialog.data("refresh-url");

    button.click(function () {
      $.ajax(refreshUrl).done(function(response) {
        userIdentitiesDialog.html(response).foundation("open");
      });
    });
  }
});
