/**
 * Returns 9 useful positions (page coordinates) of a HTMLElement regarding the window object
 *
 *    topLeft      topCenter      topRight
 *           \ ________|________ /
 *            |                 |
 * middleLeft |   middleCenter  | middleRight
 *            |_________________|
 *           /         |         \
 * bottomLeft     bottomCenter    bottomRight
 *
 * @param {HTMLElement} node target node
 * @param {HTMLElement} relativeParent relative parent, instead of window
 * @returns {Object} Nine pair of page coordinates
 */
const getAbsolutePosition = (node, relativeParent) => {
  const { top, left, width, height } = node.getBoundingClientRect()

  let [pageX, pageY] = [window.pageXOffset, window.pageYOffset]
  if (relativeParent) {
    // in order to calculate the relative parent position, we reuse this function,
    // using the parent regarding the window and substracting the topLeft corner (its relative position [0,0])
    const { topLeft: [parentX, parentY] } = getAbsolutePosition(relativeParent);
    [pageX, pageY] = [pageX - parentX, pageY - parentY]
  }

  return {
    topLeft: [pageX + left, pageY + top],
    topCenter: [pageX + left + width / 2, pageY + top],
    topRight: [pageX + left + width, pageY + top],
    middleLeft: [pageX + left, pageY + top + height / 2],
    middleCenter: [pageX + left + width / 2, pageY + top + height / 2],
    middleRight: [pageX + left + width, pageY + top + height / 2],
    bottomLeft: [pageX + left, pageY + top + height],
    bottomCenter: [pageX + left + width / 2, pageY + top + height],
    bottomRight: [pageX + left + width, pageY + top + height]
  }
}

/**
 * Initialize any tooltip in the same way, both plain texts or complex markup
 *
 * @param {HTMLElement} node trigger element who contains the tooltip
 * @returns {void}
 */
export default function(node) {
  const { tooltip: tooltipHtml } = node.dataset

  // in case of javascript disabled, the tooltip could use the title attribute as default behaviour
  // once arrives here, title is no longer necessary
  node.removeAttribute("title")

  const div = document.createElement("div")
  div.innerHTML = tooltipHtml
  const tooltip = div.firstElementChild

  tooltip.id = tooltip.id || `tooltip-${Math.random().toString(36).substring(7)}`

  const append = () => {
    document.body.appendChild(tooltip)
    node.setAttribute("aria-describedby", tooltip.id)
    tooltip.setAttribute("aria-hidden", false)

    const { topCenter, bottomCenter, middleRight, middleLeft } = getAbsolutePosition(node)

    let positionX = null;
    let positionY = null;

    if (tooltip.classList.contains("bottom")) {
      [positionX, positionY] = bottomCenter
    } else if (tooltip.classList.contains("left")) {
      [positionX, positionY] = middleLeft
    } else if (tooltip.classList.contains("right")) {
      [positionX, positionY] = middleRight
    } else if (tooltip.classList.contains("top")) {
      [positionX, positionY] = topCenter
    }

    tooltip.style.top = `${positionY}px`
    tooltip.style.left = `${positionX}px`
  }
  const remove = () => tooltip.setAttribute("aria-hidden", true)

  // keyboard listener is at root-level
  window.addEventListener("keydown", (event) => event.key === "Escape" && remove())

  node.addEventListener("mouseenter", append)
  node.addEventListener("mouseleave", remove)
  node.addEventListener("focus", append)
  node.addEventListener("blur", remove)
  tooltip.addEventListener("mouseenter", append)
  tooltip.addEventListener("mouseleave", remove)
}
