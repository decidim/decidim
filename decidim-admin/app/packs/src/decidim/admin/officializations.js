$(() => {
  const $modal = $("#show-email-modal");

  if ($modal.length === 0) {
    return
  }

  const $button = $("[data-open=user_email]", $modal);
  const $email = $("#user_email", $modal);
  const $fullName = $("#user_full_name", $modal);

  $("[data-dialog-open=show-email-modal]").on("click", (event) => {
    event.preventDefault()

    $button.show()
    $button.attr("data-remote-url", event.currentTarget.href)
    $fullName.text($(event.currentTarget).data("full-name"))
    $email.html('');
  })

  $("[data-open=user_email]").on("click", (event) => {
    getUserEmail(event.currentTarget.dataset.remoteUrl);
  })

  async function getUserEmail(url) {
    let response = await fetch(url);
    if (response.ok) {
      let userEmail = await response.text();
      $("#user_email").html(userEmail);
      $button.hide()
    } else {
      alert("Error-HTTP: " + response.status);
    }
  }

})
