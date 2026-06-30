import { Controller } from "@hotwired/stimulus"

const OPEN_DELAY_MS = 50

const FOCUSABLE_SELECTORS = "a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex='-1'])"

const getFocusableElements = (container) => {
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTORS)).filter(
    (el) => el.offsetParent !== null
  );
}

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
    this.focusTrapHandler = this.focusTrapHandler.bind(this)

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
    if (event.key !== "Escape") {
      return;
    }
    if (this.isHidden()) {
      return;
    }

    this.closeMenu()
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

  focusTrapHandler(event) {
    if (event.key !== "Tab") {
      return;
    }
    const focusable = getFocusableElements(this.menuContainer);
    if (focusable.length === 0) {
      return;
    }
    if (event.shiftKey && document.activeElement === focusable[0]) {
      event.preventDefault();
      focusable[focusable.length - 1].focus({ preventScroll: true });
    } else if (!event.shiftKey && document.activeElement === focusable[focusable.length - 1]) {
      event.preventDefault();
      focusable[0].focus({ preventScroll: true });
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
    this.menuContainer.addEventListener("keydown", this.focusTrapHandler)

    const focusable = getFocusableElements(this.menuContainer);
    if (focusable.length > 0) {
      focusable[0].focus({ preventScroll: true });
    }
  }

  closeMenu() {
    this.menuContainer.removeEventListener("keydown", this.focusTrapHandler)
    document.body.style.overflow = this.previousBodyOverflow ?? ""
    this.element.setAttribute("aria-expanded", "false")
    this.menuContainer.setAttribute("aria-hidden", "true")
    this.menuContainer.removeAttribute("aria-modal")
  }
}
