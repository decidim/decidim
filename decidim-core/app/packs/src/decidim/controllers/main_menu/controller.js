import { Controller } from "@hotwired/stimulus"


const CLOSE_BUTTON_ID = "main-dropdown-summary-desktop-close"
const OPEN_DELAY_MS = 50

export default class extends Controller {
  connect() {
    this.menuButton = this.element
    this.menuContainer = document.getElementById(this.element.dataset.target)
    this.closeButton = document.getElementById(CLOSE_BUTTON_ID)

    if (!this.menuContainer) {
      return;
    }

    this.handleButtonClick = this.handleButtonClick.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleDocumentClick = this.handleDocumentClick.bind(this)

    this.menuButton.addEventListener("click", this.handleButtonClick)
    document.addEventListener("keydown", this.handleKeydown)
    this.closeButton.addEventListener("click", this.handleDocumentClick)
  }

  disconnect() {
    if (!this.menuContainer) {
      return;
    }

    this.menuButton.removeEventListener("click", this.handleButtonClick)
    document.removeEventListener("keydown", this.handleKeydown)
    this.closeButton.removeEventListener("click", this.handleDocumentClick)
  }

  handleButtonClick() {
    if (this.isHidden()) {
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

  handleDocumentClick() {
    if (this.isHidden()) {
      return;
    }

    this.closeMenu();
  }

  isHidden() {
    return this.menuContainer.getAttribute("aria-hidden") === "true"
  }

  openMenu() {
    document.body.style.overflow = "hidden"
    this.menuContainer.setAttribute("aria-hidden", "false")
  }

  closeMenu() {
    document.body.style.overflow = "scroll"
    this.menuContainer.setAttribute("aria-hidden", "true")
  }
}
