/**
 * Toggles the visibility of an HTML element (or elements),
 * when the trigger is activated.
 *
 * @param {HTMLElement} component trigger element
 * @returns {void}
 */
export default function createToggle(component) {
  const { toggle } = component.dataset

  if (!component.id) {
    // when component has no id, we enforce it to have one
    component.id = `toggle-${Math.random().toString(36).substring(7)}`
  }

  component.setAttribute("aria-controls", toggle);
  toggle.split(" ").forEach((id) => {
    const node = document.getElementById(id)

    if (node) {
      node.setAttribute("aria-labelledby", [node.getAttribute("aria-labelledby"), component.id].filter(Boolean).join(" "))
    }
  })

  component.addEventListener("click", () => {
    toggle.split(" ").forEach((id) => {
      const node = document.getElementById(id)

      if (node) {
        node.setAttribute("aria-expanded", !node.hidden);
      }
    });

    document.dispatchEvent(new Event("on:toggle"));
  })
}
