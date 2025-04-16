const currentAllocationZero = () => {
  const $budgetSummary = $(".budget-summary__progressbox");
  return parseInt($budgetSummary.attr("data-current-allocation"), 10) === 0;
}

const isSafeUrl = (exitUrl) => {
  if (!exitUrl) {
    return false
  }

  const safeUrls = [
    $(".budget-summary").attr("data-safe-url").replace(location.origin, ""),
    `${location.pathname}#`,
    `${location.href}#`,
    "#"
  ];

  let safe = false;
  safeUrls.forEach((url) => {
    if (exitUrl.startsWith(url)) {
      safe = true
    }
  });

  return safe;
}

const allowExitFrom = ($el) => {
  if (currentAllocationZero()) {
    return true
  } else if ($el.attr("target") === "_blank") {
    return true;
  } else if ($el.parents("#loginModal").length > 0) {
    return true;
  } else if ($el.parents("#authorizationModal").length > 0) {
    return true;
  } else if ($el.attr("id") === "exit-notification-link") {
    return true;
  } else if ($el.parents("main").length > 0) {
    return true;
  } else if (isSafeUrl($el.attr("href"))) {
    return true
  } else if (document.querySelector(".panel-container") && document.querySelector(".panel-container").contains($el[0])) {
    return true
  }

  return false;
}

$(() => {
  const $exitNotification = $("#exit-notification");
  const $exitLink = $("#exit-notification-link");
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
    window.Decidim.currentDialogs["exit-notification"].open();
  };

  $(document).on("click", "a", (event) => {
    exitLinkText = defaultExitLinkText;

    const $link = $(event.currentTarget);
    if (!allowExitFrom($link)) {
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
    const linkText = $link.text();

    if (linkText.length > 0) {
      exitLinkText = linkText;
    }

    openExitNotification($link.attr("href"), $link.data("method"));
  });
  // Custom handling for the exit link which needs to change the exit link
  // text to the default text as this is not handled by the document click
  // listener.
  $("a[data-dialog-open='exit-notification']").on("click", () => {
    exitLinkText = defaultExitLinkText;
    openExitNotification(defaultExitUrl);
  });
});
