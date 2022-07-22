/**
 * Handler to allow ONLY ONE dropdown (details HTML tag) open at once.
 * To click outside or open a different dropdown will close the others.
 *
 * Adding the HTML5 attribute data-autoclose="false" to the details tag, will bypass this behaviour
 */
document.addEventListener("DOMContentLoaded", () => {
  const details = [...document.querySelectorAll('details:not([data-autoclose="false"])')];

  document.addEventListener("click", ({ target }) => {
    if (details.some((element) => element.contains(target))) {
      // click inside handler: close everything but the cliked one
      details.forEach((element) => !element.contains(target) && element.removeAttribute("open"));
    } else {
      // click outside handler: close everything
      details.forEach((element) => element.removeAttribute("open"));
    }
  });
});
