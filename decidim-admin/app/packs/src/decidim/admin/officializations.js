import { getMessages } from "src/decidim/refactor/moved/i18n";

document.addEventListener("turbo:load", () => {
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
    $email.html("");
  })

  /* eslint-disable */
  async function getUserEmail(url) {
    let response = null;
    try {
      response = await fetch(url, { redirect: "error" });
    } catch (error) {
      if (error instanceof TypeError && error.message === "Failed to fetch") {
        response = { redirectError: true };
      }
    }
    if (response && response.ok) {
      let userEmail = await response.text();
      $("#user_email").html(userEmail);
      $button.hide()
    } else if (response && response.redirectError) {
      const message = getMessages().unauthorized || "Unauthorized.";
      $("#user_email").text(message);
    } else {
      console.log(`Error-HTTP: " + ${response.status}`);
    }
  }
  /* eslint-enable */

  $("[data-open=user_email]").on("click", (event) => {
    getUserEmail(event.currentTarget.dataset.remoteUrl);
  })

})
