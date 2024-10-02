const allowExitFrom = ($el) => {
  if ($el.attr("id") === "exit-proposal-notification-link" || $el.hasClass("no-modal")) {
    return true;
  }

  return false;
}

$(() => {
  const $exitNotification = $("#exit-proposal-notification");
  const $exitLink = $("#exit-proposal-notification-link");
  const defaultExitUrl = $exitLink.attr("href");
  const defaultExitLinkText = $exitLink.text();
  const signOutPath = window.Decidim.config.get("sign_out_path");
  let exitLinkText = defaultExitLinkText;

  if ($exitNotification.length < 1) {
    // Do not apply when not inside the voting pipeline
    return;
  }

  const openExitNotification = (url, method = null) => {
    if (method && method !== "get") {
      $exitLink.attr("data-method", method);
    } else {
      $exitLink.removeAttr("data-method");
    }

    $exitLink.attr("href", url);
    $exitLink.text(exitLinkText);
    window.Decidim.currentDialogs["exit-proposal-notification"].open();
  };

  $(document).on("click", "a", (event) => {
    exitLinkText = defaultExitLinkText;

    const $link = $(event.currentTarget);
    if (!allowExitFrom($link) && !$(window.Decidim.currentDialogs["exit-proposal-notification"].dialog.querySelector("[data-dialog-container]")).data("minimum-votes-reached")) {
      event.preventDefault();
      openExitNotification($link.attr("href"), $link.data("method"));
    }
  });
  // Custom handling for the header sign out so that it will not trigger the
  // logout form submit and so that it changes the exit link text. This does
  // not trigger the document link click listener because it has the
  // data-method attribute to trigger a form submit event.
  $(`[href='${signOutPath}']`).on("click", (event) => {
    event.preventDefault();
    event.stopPropagation();

    const $link = $(event.currentTarget);
    exitLinkText = $link.text();
    openExitNotification($link.attr("href"), $link.data("method"));
  });
  // Custom handling for the exit link which needs to change the exit link
  // text to the default text as this is not handled by the document click
  // listener.
  $("a[data-dialog-open='exit-proposal-notification']").on("click", () => {
    exitLinkText = defaultExitLinkText;
    openExitNotification(defaultExitUrl);
  });
});
