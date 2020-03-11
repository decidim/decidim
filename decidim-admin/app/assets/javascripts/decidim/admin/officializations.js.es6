$(() => {
  const $modal = $("#showEmailModal");

  if ($modal.length === 0) {
    return
  }

  const $button = $("[data-open=user_email]", $modal);
  const $email = $("#user_email", $modal);
  const $fullName = $("#user_full_name", $modal);

  $("[data-toggle=showEmailModal]").on("click", (event) => {
    event.preventDefault()

    $button.show()
    $button.attr("data-open-url", event.currentTarget.href)
    $fullName.text($(event.currentTarget).data("full-name"))
    $email.html("")
  })
})
