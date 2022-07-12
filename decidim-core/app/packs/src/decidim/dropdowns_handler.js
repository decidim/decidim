/**
 * Handler to allow ONLY ONE dropdown (details HTML tag) open at once.
 * To click outside or open a different dropdown will close the others.
 */
document.addEventListener("DOMContentLoaded", () => {
  const details = [...document.querySelectorAll("details")];

  document.addEventListener("click", ({ target }) => {
    if (details.some((element) => element.contains(target)).length !== 0) {
      details.forEach((element) => element.removeAttribute("open"));
    }
  });
});
