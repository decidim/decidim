import { Controller } from "@hotwired/stimulus"

/**
 * Tooltip Stimulus Controller
 *
 * Usage:
 * <button data-controller="tooltip" data-tooltip-tooltip-value="<div class='tooltip top'>Tooltip content</div>">
 *   Hover me
 * </button>
 *
 * Or with data attribute:
 * <button data-controller="tooltip" data-tooltip-tooltip-value="<div class='tooltip bottom'>Content</div>">
 *   Click me
 * </button>
 */
export default class extends Controller {
  static get values() {
    return {
      tooltip: String
    }
  }

  connect() {
    this.tooltip = null
    this.useMobile = (/Mobi|Android/i).test(navigator.userAgent)
    this.outsideClickHandler = this.handleOutsideClick.bind(this)


    if (!this.tooltipValue) {
      return
    }

    const div = document.createElement("div")
    div.innerHTML = this.tooltipValue
    this.tooltip = div.firstElementChild

    // only run this script when the tooltip content is html
    if (!(this.tooltip instanceof HTMLElement)) {
      return
    }

    this.setupTooltip()
    this.bindEvents()
  }

  disconnect() {
    this.cleanup()
  }

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
  getAbsolutePosition(node, relativeParent) {

    const { top, left, width, height } = node.getBoundingClientRect()

    let [pageX, pageY] = [window.pageXOffset, window.pageYOffset]
    if (relativeParent) {
      const { topLeft: [parentX, parentY] } = this.getAbsolutePosition(relativeParent)
        // eslint-disable-next-line no-use-before-define,no-sequences
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
   * Setup tooltip attributes
   * @returns {void}
   */
  setupTooltip() {
    // in case of javascript disabled, the tooltip could use the title attribute as default behaviour
    // once arrives here, title is no longer necessary
    this.element.removeAttribute("title")

    this.tooltip.id = this.tooltip.id || `tooltip-${Math.random().toString(36).substring(7)}`
    // append to dom hidden, to apply css transitions
    this.tooltip.setAttribute("aria-hidden", true)
  }

  /**
   * Calculate and set tooltip position based on its classes
   * @returns {void}
   */
  positionTooltip() {
    const { topCenter, bottomCenter, middleRight, middleLeft } = this.getAbsolutePosition(this.element)

    let positionX = null
    let positionY = null

    if (this.tooltip.classList.contains("bottom")) {
      [positionX, positionY] = bottomCenter
    } else if (this.tooltip.classList.contains("left")) {
      [positionX, positionY] = middleLeft
    } else if (this.tooltip.classList.contains("right")) {
      [positionX, positionY] = middleRight
    } else if (this.tooltip.classList.contains("top")) {
      [positionX, positionY] = topCenter
    }

    // when the node is placed at the left side of the screen
    // we translate the tooltip's arrow in order to fit inside the viewport
    if ((this.tooltip.classList.contains("top") || this.tooltip.classList.contains("bottom")) &&
      positionX < Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0) * 0.5) {
      this.tooltip.style.setProperty("--arrow-offset", "80%")
    } else {
      this.tooltip.style.removeProperty("--arrow-offset")
    }

    this.tooltip.style.top = `${positionY}px`
    this.tooltip.style.left = `${positionX}px`
  }

  /**
   * Show tooltip
   * @param {Event} event - The click event from the toggle button
   * @returns {void}
   */
  showTooltip(event) {
    if (event) {
      event.preventDefault()
    }

    // remove any previous tooltip from the DOM, in order to avoid overlaps
    this.removeAllTooltips()

    document.body.appendChild(this.tooltip)
    this.element.setAttribute("aria-describedby", this.tooltip.id)

    // the position must be calculated once the event has been triggered
    // in that way, we ensure the container position is that we want
    // otherwise, the trigger could be hidden or misplaced
    this.positionTooltip()

    this.tooltip.setAttribute("aria-hidden", false)

    // sleep time before hiding the element from the DOM
    setTimeout(() => document.addEventListener("click", this.outsideClickHandler))
  }

  /**
   * Hide tooltip
   * @returns {void}
   */
  hideTooltip() {
    if (this.tooltip) {
      this.tooltip.setAttribute("aria-hidden", "true")
      document.removeEventListener("click", this.outsideClickHandler)
    }
  }

  /**
   * Toggle tooltip visibility
   * @param {Event} event - The click event from the toggle button
   * @returns {void}
   */
  toggleTooltip(event) {
    if (event) {
      event.preventDefault()
    }

    // if the tooltip is visible in the DOM, hide it otherwise display
    if (this.tooltip && this.tooltip.getAttribute("aria-hidden") === "false") {
      this.hideTooltip()
      return
    }

    this.showTooltip(event)
  }

  /**
   * Handle outside clicks to close tooltip
   * @param {Event} event - The click event from outside the button
   * @returns {void}
   */
  handleOutsideClick(event) {
    if (!this.tooltip.contains(event.target) && event.target !== this.element) {
      this.hideTooltip()
    }
  }

  /**
   * Handle escape key to close tooltip
   * @param {Event} event - The keyboard event
   * @returns {void}
   */
  handleEscapeKey(event) {
    if (event.key === "Escape") {
      this.hideTooltip()
    }
  }

  /**
   * Remove all existing tooltips from DOM to avoid overlaps
   * @returns {void}
   */
  removeAllTooltips() {
    Array.from(document.body.children).
      filter((child) => child.id && child.id.startsWith("tooltip")).
      forEach((child) => child.remove())
  }

  /**
   * Bind appropriate events based on device type
   * @returns {void}
   */
  bindEvents() {
    if (this.useMobile) {
      this.bindMobileEvents()
    } else {
      this.bindDesktopEvents()
    }
  }

  /**
   * Bind mobile-specific events (click and keyboard)
   * @returns {void}
   */
  bindMobileEvents() {
    this.element.addEventListener("click", (event) => this.toggleTooltip(event))
    window.addEventListener("keydown", (event) => this.handleEscapeKey(event))
  }

  /**
   * Bind desktop-specific events (hover and focus)
   * @returns {void}
   */
  bindDesktopEvents() {
    this.element.addEventListener("mouseenter", (event) => this.showTooltip(event))
    this.element.addEventListener("mouseleave", () => this.hideTooltip())
    this.element.addEventListener("focus", (event) => this.showTooltip(event))
    this.element.addEventListener("blur", () => this.hideTooltip())

    // tooltip hover listeners to prevent hiding when hovered
    if (this.tooltip) {
      this.tooltip.addEventListener("mouseenter", () => {
        this.tooltip.setAttribute("aria-hidden", false)
      })
      this.tooltip.addEventListener("mouseleave", () => this.hideTooltip())
    }
  }

  /**
   * Clean up when controller disconnects
   * @returns {void}
   */
  cleanup() {
    if (this.tooltip && this.tooltip.parentNode) {
      this.tooltip.parentNode.removeChild(this.tooltip)
    }
    document.removeEventListener("click", this.outsideClickHandler)
    window.removeEventListener("keydown", (event) => this.handleEscapeKey(event))
  }

  /**
   * Handle tooltip value changes
   * @returns {void}
   */
  tooltipValueChanged() {
    if (this.tooltip) {
      this.cleanup()
    }
    this.initialize()
  }
}
