/**
 * Hack for the mouse events of the breadcrumb dropdowns
 * Since they're opened via hover event, at the moment you hover something else, the dropdown begins to close
 * In order to avoid that, this script includes a set of statements to reopen the element
 * as long as the conditions are fulfilled (during the fade away effect)
 *
 * Use [data-enhance-dropdown] to inform about the dropdown trigger node
 *
 * @param {HTMLElement} element dropdown node
 * @returns {void}
 */
export default function enhanceBreadcrumbDropdownEvents(element) {
  const { enhanceDropdown } = element.dataset

  element.addEventListener("transitionend", ({ target }) => {
    target.allowReopen = false;
    target.style.pointerEvents = "none"
  });

  element.addEventListener("transitionstart", ({ target }) => {
    target.allowReopen = true;
    target.style.pointerEvents = "auto"
  });

  element.addEventListener("mouseenter", ({ target }) => target.allowReopen && target.getAttribute("aria-hidden") === "true" && document.querySelector(enhanceDropdown).click())
}
