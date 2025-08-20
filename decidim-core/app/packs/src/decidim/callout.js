/**
 * Improves the accessibility of the callout messages for screen readers. Not
 * all screen readers would announce the callout alert contents after the page
 * reload without this.
 */

document.addEventListener("turbo:load", () => {
  const callout = document.querySelector(".flash[role='alert']");
  if (!callout) {
    return;
  }

  const message = callout.querySelector(".flash__message");

  callout.setAttribute("tabindex", "0");
  setTimeout(() => {
    callout.setAttribute("tabindex", "0");
    callout.focus();

    // The content insertion is to try to hint some of the screen readers
    // that the alert content has changed and needs to be announced.
    callout.innerHTML += "&nbsp;";
  }, 500);

});
