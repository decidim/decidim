/**
 * Changes "Back to list" links to the one saved in sessionStorage API
 * To apply this to a link, at least one element must have the class "js-back-to-list".
 * For this to work it needs the filteredParams in SessionStorage, that's saved on FormFilterComponent.
 * @param {HTMLElement} links - Hyperlinks elements that point to the filters page that will use the fitererd params
 * @returns {void}
 */
export default function backToListLink(links) {

  if (!links) {
    return;
  }

  if (!window.sessionStorage) {
    return;
  }

  const filteredParams = JSON.parse(sessionStorage.getItem("filteredParams")) || {};
  links.forEach((link) => {
    const href = link.getAttribute("href");
    if (filteredParams[href]) {
      link.setAttribute("href", filteredParams[href]);
    }
  });

}
