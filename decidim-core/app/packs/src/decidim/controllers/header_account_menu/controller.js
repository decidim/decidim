import { Controller } from "@hotwired/stimulus"

/**
 * changes the value "menu" of role attribute set by a11y on div dropdown-menu-account and
 * dropdown-menu-account-mobile which are inappropriate for accessibility
 */
export default class extends Controller {
  connect() {
    const dropdownMobileDiv = document.querySelector("#dropdown-menu-account-mobile");

    this.timeoutId = setTimeout(() => {
      this.element.setAttribute("role", "dialog")
      dropdownMobileDiv.setAttribute("role", "dialog")
    }, 300)
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }
}
