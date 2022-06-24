/**
 * Scroll smoothly to the last message automatically when the page is fully loaded.
 * To apply this to a page, at least one element must have the class "scroll-to-last-message".
 * @returns {void}
 */
export default function() {
  const element = document.querySelector("[data-scroll-bottom]")
  if (element && element.children.length) {
    const lastChild = [...element.children].pop()
    const { top } = lastChild.getBoundingClientRect()
    window.scrollTo({ top: top - 16, behavior: "smooth" });
  }
}
