/**
 * Initialize the tooltips and assign them
 *
 * @param {HTMLElement} node target node
 * @returns {void}
 */
export default function(node) {
  const { firstElementChild: trigger, lastElementChild: tooltip } = node

  const hide = () => {
    tooltip.classList.add("is-hidden")
    tooltip.setAttribute("aria-hidden", true)
  }
  const show = () => {
    tooltip.classList.remove("is-hidden")
    tooltip.setAttribute("aria-hidden", false)
  }

  // default behaviour
  hide()
  trigger.setAttribute("aria-describedby", tooltip.id)

  // keyboard listener is at root-level
  window.addEventListener("keydown", (event) => event.key === "Escape" && hide())

  trigger.addEventListener("mouseenter", show)
  trigger.addEventListener("focus", show)
  trigger.addEventListener("mouseleave", hide)
  trigger.addEventListener("blur", hide)
}
