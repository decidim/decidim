const allowExitFrom = (el) => {
  if (el.id === "exit-proposal-notification-link" || el.classList.contains("no-modal")) {
    return true;
  }

  return false;
};

document.addEventListener("DOMContentLoaded", () => {
  const exitNotification = document.getElementById("exit-proposal-notification");
  const exitLink = document.getElementById("exit-proposal-notification-link");
  if (!exitLink) {
    return;
  }
  const defaultExitUrl = exitLink.href;
  const defaultExitLinkText = exitLink.textContent;
  const signOutPath = window.Decidim.config.get("sign_out_path");
  let exitLinkText = defaultExitLinkText;

  if (!exitNotification) {
    // Do not apply when not inside the voting pipeline
    return;
  }

  const openExitNotification = (url, method = null) => {
    if (method && method !== "get") {
      exitLink.setAttribute("data-method", method);
    } else {
      exitLink.removeAttribute("data-method");
    }

    exitLink.setAttribute("href", url);
    exitLink.textContent = exitLinkText;
    window.Decidim.currentDialogs["exit-proposal-notification"].open();
  };

  const handleClicks = (link) => {
    link.addEventListener("click", (event) => {
      exitLinkText = defaultExitLinkText;

      if (
        !allowExitFrom(link) &&
        ((window.Decidim.currentDialogs["exit-proposal-notification"].dialog.querySelector("[data-dialog-container]")).dataset.minimumVotesReached !== "true") &&
        ((window.Decidim.currentDialogs["exit-proposal-notification"].dialog.querySelector("[data-dialog-container]")).dataset.minimumVotesCount > 0)
      ) {
        event.preventDefault();
        openExitNotification(link.getAttribute("href"), link.dataset.method);
      }
    });
  };

  document.querySelectorAll("a").forEach(handleClicks);
  // Custom handling for the header sign-out link
  const signOutLink = document.querySelector(`[href='${signOutPath}']`);
  if (signOutLink) {
    signOutLink.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();

      exitLinkText = signOutLink.textContent;
      openExitNotification(signOutLink.getAttribute("href"), signOutLink.dataset.method);
    });
  }

  // Custom handling for links that open the exit notification dialog
  const dialogOpenLinks = document.querySelectorAll("a[data-dialog-open='exit-proposal-notification']");
  dialogOpenLinks.forEach((link) => {
    link.addEventListener("click", () => {
      exitLinkText = defaultExitLinkText;
      openExitNotification(defaultExitUrl);
    });
  });
});
