/**
 * Scroll smoothly to the last message automatically when the page is fully loaded.
 * To apply this to a page, at least one element must have the class "scroll-to-last-message".
 *
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node = document) {
  const element = node.querySelector("[data-scroll-last-child]")
  if (element && element.children.length) {
    const lastChild = [...element.children].pop()
    window.scrollTo({ top: lastChild.offsetTop, behavior: "smooth" });
  }
}
