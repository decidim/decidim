$(() => {
  const $modal = $("#showEmailModal");

  if ($modal.length == 0) {
  	return
  }

  const $button = $("[data-open=user_email]", $modal);
  const $email = $("#user_email", $modal);
  const $full_name = $("#user_full_name", $modal);

  $("[data-toggle=showEmailModal]").on("click", (event) => {
  	event.preventDefault()

  	$button.attr("data-open-url", event.currentTarget.href)
  	$full_name.text($(event.currentTarget).data("full-name"))
  	$email.html("")
  })
})