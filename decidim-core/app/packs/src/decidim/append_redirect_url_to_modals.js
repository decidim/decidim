/* eslint-disable multiline-ternary */

/*
 *
 * This is used to make sure users are redirected to
 * the expected URL after sign in.
 *
 * When a button or link trigger a login modal we capture
 * the event and inject the URL where the user should
 * be redirected after sign in (the redirect_url param).
 *
 * The code is injected to any form or link in the modal
 * and when the modal is closed we remove the injected
 * code.
 *
 * In order for this to work the button or link must have
 * a data-open attribute with the ID of the modal to open
 * and a data-redirect-url attribute with the URL to redirect
 * the user. If any of this is missing no code will be
 * injected.
 *
 */
document.addEventListener("turbo:load", () => {
  const removeUrlParameter = (url, parameter) => {
    const urlParts = url.split("?");

    if (urlParts.length >= 2) {
      // Get first part, and remove from array
      const urlBase = urlParts.shift();

      // Join it back up
      const queryString = urlParts.join("?");

      const prefix = `${encodeURIComponent(parameter)}=`;
      const parts = queryString.split(/[&;]/g);

      // Reverse iteration as may be destructive
      for (let index = parts.length - 1; index >= 0; index -= 1) {
        // Idiom for string.startsWith
        if (parts[index].lastIndexOf(prefix, 0) !== -1) {
          parts.splice(index, 1);
        }
      }

      if (parts.length === 0) {
        return urlBase;
      }

      return `${urlBase}?${parts.join("&")}`;
    }

    return url;
  }

  document.querySelectorAll("[data-dialog-open]").forEach((link) => {
    link.addEventListener("click", (event) => {
      let target = event.target.closest("a");

      const dialogTarget = document.getElementById(target.dataset.dialogOpen)
      const redirectUrl = target.dataset.redirectUrl;

      if (!dialogTarget && !redirectUrl) {
        return;
      }

      let redirectUrlInput = dialogTarget.querySelector("#redirect_url");

      if (!redirectUrlInput) {
        redirectUrlInput = `<input type="hidden" id="redirect_url" name="redirect_url" value="${redirectUrl}">`;

        dialogTarget.querySelector("form").insertAdjacentHTML("beforeend", redirectUrlInput);
      }

      redirectUrlInput.value = redirectUrl

      const queryString = new URLSearchParams({ "redirect_url": redirectUrl }).toString();

      dialogTarget.querySelectorAll("a").forEach((anchor) => {
        const currentHref = anchor.getAttribute("href");
        if (currentHref) {
          const separator = currentHref.includes("?") ? "&" : "?";

          anchor.setAttribute("href", currentHref + separator + queryString);
        }
      });
    })
  });

  $(document).on("closed.zf.reveal", (event) => {
    $("#redirect_url", event.target).remove();
    $("a", event.target).attr("href", (index, href) => {
      if (href && href.indexOf("redirect_url") !== -1) {
        return removeUrlParameter(href, "redirect_url");
      }

      return href;
    });
  });
});
