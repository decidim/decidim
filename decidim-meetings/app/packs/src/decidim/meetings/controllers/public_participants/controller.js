import { Controller } from "@hotwired/stimulus"
import { screens } from "tailwindcss/defaultTheme"

const DESKTOP_MEDIA_QUERY = `(min-width: ${screens.md})`
const HIDDEN_CLASS = "hidden"
const DEFAULT_DESKTOP_COUNT = 12
const DEFAULT_MOBILE_COUNT = 8


// Stimulus controller for meeting public participants list.
export default class extends Controller {

  /**
   * Initializes the controller state and media query listeners.
   *
   * @returns {void}
   */
  connect() {
    this.expanded = false
    this.mediaQuery = window.matchMedia(DESKTOP_MEDIA_QUERY)
    this.items = Array.from(this.element.querySelectorAll("[data-participants-item]"))
    this.toggleButton = this.element.querySelector("[data-participants-toggle]")
    this.moreState = this.element.querySelector("[data-participants-toggle-more]")
    this.lessState = this.element.querySelector("[data-participants-toggle-less]")
    this.desktopCount = this.countFromDataset("desktopCount", DEFAULT_DESKTOP_COUNT)
    this.mobileCount = this.countFromDataset("mobileCount", DEFAULT_MOBILE_COUNT)

    if (!this.toggleButton || this.items.length === 0) {
      return
    }

    this.refreshOnChange = this.refresh.bind(this)

    this.toggleButton.setAttribute("aria-expanded", "false")
    this.updateToggleText()

    if (this.mediaQuery.addEventListener) {
      this.mediaQuery.addEventListener("change", this.refreshOnChange)
    } else {
      this.mediaQuery.addListener(this.refreshOnChange)
    }

    this.refresh()
  }

  /**
   * Cleans up media query listeners.
   *
   * @returns {void}
   */
  disconnect() {
    if (!this.mediaQuery || !this.toggleButton) {
      return
    }

    if (this.mediaQuery.removeEventListener) {
      this.mediaQuery.removeEventListener("change", this.refreshOnChange)
    } else {
      this.mediaQuery.removeListener(this.refreshOnChange)
    }
  }

  /**
   * Toggles the expanded state for the participants list.
   *
   * @returns {void}
   */
  toggle() {
    this.expanded = !this.expanded
    this.toggleButton.setAttribute("aria-expanded", this.expanded.toString())
    this.refresh()
  }

  /**
   * Refreshes the list visibility and toggle state.
   *
   * @returns {void}
   */
  refresh() {
    const visibleCount = this.visibleCountForViewport()

    if (this.items.length <= visibleCount) {
      this.expanded = false
      this.toggleButton.setAttribute("aria-expanded", "false")
      this.toggleButton.classList.add(HIDDEN_CLASS)
      this.updateToggleText()
      this.applyVisibility(visibleCount, false)
      return
    }

    this.toggleButton.classList.remove(HIDDEN_CLASS)
    this.updateToggleText()

    this.applyVisibility(visibleCount, this.expanded)
  }

  /**
   * Resolves the visible count based on current viewport.
   *
   * @returns {number} Visible count for the current viewport.
   */
  visibleCountForViewport() {
    return this.mediaQuery.matches
      ? this.desktopCount
      : this.mobileCount
  }

  /**
   * Updates the toggle label visibility.
   *
   * @returns {void}
   */
  updateToggleText() {
    if (!this.moreState || !this.lessState) {
      return
    }

    this.moreState.classList.toggle(HIDDEN_CLASS, this.expanded)
    this.lessState.classList.toggle(HIDDEN_CLASS, !this.expanded)
  }

  /**
   * Applies visibility to participant items.
   *
   * @param {number} visibleCount - Number of visible participants to keep.
   * @param {boolean} expanded - Whether the list is expanded.
   * @returns {void}
   */
  applyVisibility(visibleCount, expanded) {
    this.items.forEach((item, index) => {
      const shouldHide = !expanded && index >= visibleCount
      item.classList.toggle(HIDDEN_CLASS, shouldHide)
    })
  }

  countFromDataset(key, fallback) {
    const value = Number(this.element.dataset[key])
    return Number.isNaN(value)
      ? fallback
      : value
  }
}
