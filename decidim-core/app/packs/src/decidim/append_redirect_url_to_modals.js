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
 * We use event delegation on document so that [data-dialog-open]
 * elements added dynamically (e.g. via AJAX/Turbo Streams or
 * dynamic_fields.component.js) also receive the click handler.
 *
 */
document.addEventListener("click", (event) => {
  const target = event.target.closest("[data-dialog-open]");

  if (!target) {
    return;
  }

  const dialogTarget = document.getElementById(target.dataset.dialogOpen);
  const redirectUrl = target.dataset.redirectUrl;

  if (!dialogTarget || !redirectUrl) {
    return;
  }

  let redirectUrlInput = dialogTarget.querySelector("#redirect_url");

  if (!redirectUrlInput) {
    redirectUrlInput = `<input type="hidden" id="redirect_url" name="redirect_url" value="${redirectUrl}">`;

    let form = dialogTarget.querySelector("form");

    if (form) {
      form.insertAdjacentHTML("beforeend", redirectUrlInput);
      redirectUrlInput = dialogTarget.querySelector("#redirect_url");
    }
  }

  if (redirectUrlInput instanceof HTMLElement) {
    redirectUrlInput.value = redirectUrl;
  }

  dialogTarget.querySelectorAll("a").forEach((anchor) => {
    const currentHref = anchor.getAttribute("href");
    if (currentHref) {
      const url = new URL(currentHref, window.location.origin);
      url.searchParams.set("redirect_url", redirectUrl);
      anchor.setAttribute("href", url.toString());
    }
  });
});
