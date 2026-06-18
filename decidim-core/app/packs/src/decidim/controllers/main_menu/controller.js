import { Controller } from "@hotwired/stimulus"

const OPEN_DELAY_MS = 50
const FOCUSABLE_SELECTOR = "a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex='-1'])"

/**
 * Main menu dropdown controller and traps page scroll while the menu is open.
 *
 * Expected markup:
 * - The controller element has a `data-target` attribute with the menu container id.
 * - The menu container uses `aria-hidden="true|false"` for visibility.
 * - An optional close button exists with id `main-dropdown-summary-desktop-close`.
 */
export default class extends Controller {
  connect() {
    this.menuButton = this.element
    this.menuContainer = document.getElementById(this.element.dataset.target)
    this.closeButton = document.getElementById(this.element.dataset.closeButton)

    if (!this.menuContainer) {
      return;
    }

    this.handleContainerClick = this.handleContainerClick.bind(this)
    this.handleButtonClick = this.handleButtonClick.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleCloseButtonClick = this.handleCloseButtonClick.bind(this)

    this.menuButton.addEventListener("click", this.handleButtonClick)
    this.menuContainer.addEventListener("click", this.handleContainerClick)


    document.addEventListener("keydown", this.handleKeydown)
    if (this.closeButton) {
      this.closeButton.addEventListener("click", this.handleCloseButtonClick)
    }
  }

  disconnect() {
    if (!this.menuContainer) {
      return;
    }

    this.menuButton.removeEventListener("click", this.handleButtonClick)
    this.menuContainer.removeEventListener("click", this.handleContainerClick)
    document.removeEventListener("keydown", this.handleKeydown)
    if (this.closeButton) {
      this.closeButton.removeEventListener("click", this.handleCloseButtonClick)
    }
    if (!this.isHidden()) {
      this.closeMenu();
    }
  }


  handleContainerClick(event) {
    if (this.isHidden()) {
      return;
    }
    if (event.target !== this.menuContainer) {
      return;
    }
    this.closeMenu()
  }

  handleButtonClick() {
    if (!this.isHidden()) {
      return;
    }

    setTimeout(() => {
      this.openMenu()
      window.scrollTo({ top: 0, behavior: "smooth" })
    }, OPEN_DELAY_MS)
  }

  handleKeydown(event) {
    if (this.isHidden()) {
      return;
    }

    if (event.key === "Escape") {
      this.closeMenu()
      return;
    }

    if (event.key === "Tab") {
      this.handleFocusTrap(event)
    }
  }

  handleCloseButtonClick() {
    if (this.isHidden()) {
      return;
    }

    this.closeMenu();
  }

  isHidden() {
    return this.menuContainer.getAttribute("aria-hidden") === "true"
  }

  getFocusableElements() {
    return Array.from(this.menuContainer.querySelectorAll(FOCUSABLE_SELECTOR)).filter(
      (element) => !element.disabled && (element.offsetWidth > 0 || element.offsetHeight > 0)
    )
  }

  handleFocusTrap(event) {
    const focusable = this.getFocusableElements()

    if (focusable.length === 0) {
      return;
    }

    const firstElement = focusable[0]
    const lastElement = focusable[focusable.length - 1]

    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault()
      lastElement.focus({ preventScroll: true })
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault()
      firstElement.focus({ preventScroll: true })
    }
  }

  openMenu() {
    if (typeof this.previousBodyOverflow === "undefined") {
      this.previousBodyOverflow = document.body.style.overflow;
    }
    document.body.style.overflow = "hidden"
    this.element.setAttribute("aria-expanded", "true")
    this.menuContainer.setAttribute("aria-hidden", "false")
    this.menuContainer.setAttribute("aria-modal", "true")

    if (window.focusGuard) {
      window.focusGuard.trap(this.menuContainer, this.menuButton)
    }

    const focusable = this.getFocusableElements()
    if (focusable.length > 0) {
      focusable[0].focus({ preventScroll: true })
    }
  }

  closeMenu() {
    document.body.style.overflow = this.previousBodyOverflow ?? ""
    this.element.setAttribute("aria-expanded", "false")
    this.menuContainer.setAttribute("aria-hidden", "true")
    this.menuContainer.removeAttribute("aria-modal")

    if (window.focusGuard) {
      window.focusGuard.disable()
    } else {
      this.menuButton.focus({ preventScroll: true })
    }
  }
}
