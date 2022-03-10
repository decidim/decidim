/**
 * Changes "Back to list" links to the one saved in sessionStorage API
 * To apply this to a link, at least one element must have the class "js-back-to-list".
 * For this to work it needs the filteredParams in SessionStorage, that's saved on FormFilterComponent.
 * @returns {void}
 */
export default function backToListLink() {

  if (!document.querySelector(".js-back-to-list")) {
    return;
  }

  if (!window.sessionStorage) {
    return;
  }

  const filteredParams = JSON.parse(sessionStorage.getItem("filteredParams")) || {};
  document.querySelectorAll(".js-back-to-list").forEach((link) => {
    const href = link.getAttribute("href");
    if (filteredParams[href]) {
      link.setAttribute("href", filteredParams[href]);
    }
  });

}
