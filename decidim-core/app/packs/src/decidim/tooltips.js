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
    // using the parent regarding the window and subtracting the topLeft corner (its relative position [0,0])
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

  const div = document.createElement("div")
  div.innerHTML = tooltipHtml
  const tooltip = div.firstElementChild

  // only run this script when the tooltip content is html
  if (!(tooltip instanceof HTMLElement)) {
    return
  }

  // in case of javascript disabled, the tooltip could use the title attribute as default behaviour
  // once arrives here, title is no longer necessary
  node.removeAttribute("title")

  tooltip.id = tooltip.id || `tooltip-${Math.random().toString(36).substring(7)}`
  // append to dom hidden, to apply css transitions
  tooltip.setAttribute("aria-hidden", true)

  // Used to detect if the user is on a mobile device by checking the user agent
  const useMobile = (/Mobi|Android/i).test(navigator.userAgent);

  const toggleTooltip = (event) => {
    event.preventDefault();
    // if the tooltip is visable in the dom, hide it otherwise display
    if (tooltip.getAttribute("aria-hidden") === "false") {
      tooltip.setAttribute("aria-hidden", "true");
      return
    }

    // remove any previous tooltip from the DOM, in order to avoid overlaps
    Array.from(document.body.children).map((child) => child.id.startsWith("tooltip") && child.remove())

    document.body.appendChild(tooltip)

    node.setAttribute("aria-describedby", tooltip.id)

    // the position must be calculated once the event has been triggered
    // in that way, we ensure the container position is that we want
    // otherwise, the trigger could be hidden or misplaced
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

    // when the node is placed at the left side of the screen
    // we translate the tooltip's arrow in order to fit inside the viewport
    if ((tooltip.classList.contains("top") || tooltip.classList.contains("bottom")) && positionX < Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0) * 0.5) {
      tooltip.style.setProperty("--arrow-offset", "80%")
    } else {
      tooltip.style.removeProperty("--arrow-offset")
    }

    tooltip.style.top = `${positionY}px`
    tooltip.style.left = `${positionX}px`

    tooltip.setAttribute("aria-hidden", false)
  }

  // function to hide the tooltip
  const removeTooltip = () => {
    tooltip.setAttribute("aria-hidden", "true");
  }

  if (useMobile) {
    // mobile use to click and toggle the tooltip
    node.addEventListener("click", toggleTooltip);
    window.addEventListener("keydown", (event) => event.key === "Escape" && removeTooltip())
  } else {
    // desktop use for hover and blur over tooltip
    node.addEventListener("mouseenter", toggleTooltip)
    node.addEventListener("mouseleave", removeTooltip)
    node.addEventListener("focus", toggleTooltip)
    node.addEventListener("blur", removeTooltip)

    // tooltip hover listeners to prevent hiding when hovered
    tooltip.addEventListener("mouseenter", () => tooltip.setAttribute("aria-hidden", false))
    tooltip.addEventListener("mouseleave", removeTooltip)
  }
}
