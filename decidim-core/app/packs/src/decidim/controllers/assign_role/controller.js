import { Controller } from "@hotwired/stimulus"

/**
 * This controller is used to set a role attribute for any element where is being assigned.
 * It requires a data-role attribute with the value of the role attribute to be set.
 * We are using to change the value "menu" of role attribute set by a11y on div dropdown-menu-account and
 * dropdown-menu-account-mobile which are inappropriate for accessibility
 */
export default class extends Controller {
  connect() {
    const role = this.element.dataset.role

    if (!role) {
      return
    }

    this.timeoutId = setTimeout(() => {
      this.element.setAttribute("role", role)
    }, 300)
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }
}
